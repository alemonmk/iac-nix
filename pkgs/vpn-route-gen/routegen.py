from aggregate6 import aggregate
from pathlib import Path
from subprocess import check_output as run_command
import urllib.request
import dns.resolver
import math
import json


def main():
    aggregated = []
    unaggregated_routes = []

    # Whois by bgpq4
    target_as = [
        "as15133",  # Edgecast
    ]
    for dest in target_as:
        print(f"Processing {dest}...")
        retrieved_routes = run_command(
            ["/usr/bin/bgpq4", "-b", dest], encoding="utf-8", text=True
        ).splitlines()
        lines = [route.strip(" ,\n") for route in retrieved_routes[1:-2]]
        unaggregated_routes += lines

    # CountryIP from APNIC
    print("Processing Japanese IP ranges...")
    with urllib.request.urlopen(
        "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest"
    ) as u:
        res = u.read().decode("utf-8").split("\n")
        lines = [x.split("|") for x in res if x.startswith("apnic|JP|ipv4|")]
        lines = [f"{x[3]}/{32 - int(math.log2(int(x[4])))}" for x in lines]
        unaggregated_routes += lines

    # Cloudfront Global, ap-northeast-*, S3 eu-*
    print("Processing Cloudfront Global and ap-northeast-*...")
    with urllib.request.urlopen("https://ip-ranges.amazonaws.com/ip-ranges.json") as u:
        aws_ranges = json.load(u)
        cf_jp_global = [
            p["ip_prefix"]
            for p in aws_ranges["prefixes"]
            if p["service"] == "CLOUDFRONT"
            and p["region"] in ["GLOBAL", "ap-northeast-1", "ap-northeast-3"]
        ]
        ec2_jp = [
            p["ip_prefix"]
            for p in aws_ranges["prefixes"]
            if p["service"] in ["EC2"]
            and p["region"] in ["ap-northeast-1", "ap-northeast-3"]
        ]
        unaggregated_routes += cf_jp_global
        unaggregated_routes += ec2_jp

    # Individual domain names
    domains = [
        "science.nrlmry.navy.mil",
        "ipv4.imgur.map.fastly.net"
    ]
    r = dns.resolver.Resolver(configure=False)
    r.nameservers = ["10.85.10.1"]
    for domain in domains:
        print(f"Processing {domain}...")
        ans = r.resolve(domain, "A")
        for rr in ans:
            unaggregated_routes += [f"{rr.address}/32"]

    # Additional routes
    print("Processing additional individual routes...")
    unaggregated_routes += [
        "151.101.108.0/22",  # fastly jpn nodes
        "151.101.40.0/22",
        "151.101.52.0/22",
        "8.255.0.0/16",  # tlu.dl.delivery.mp.microsoft.com Lumen CDN
    ]

    aggregated = aggregate(unaggregated_routes)

    with open(
        Path("/etc/bird/reroute-via-vpn.conf"),
        mode="w",
        encoding="utf-8",
        errors="strict",
    ) as f:
        for route in aggregated:
            f.write(f'route {route} via "eth0";\n')

    print(run_command(["/usr/sbin/birdc", "configure"], encoding="utf-8", text=True))
