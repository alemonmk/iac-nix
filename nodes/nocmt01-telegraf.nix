{config, ...}: {
  services.telegraf = {
    enable = true;
    environmentFiles = [config.sops.secrets.monitoring-creds.path];
    extraConfig = {
      agent = {
        snmp_translator = "gosmi";
      };
      inputs = {
        snmp = [
          # ups
          {
            agents = ["udp://10.88.0.3:161"];
            version = 3;
            sec_name = "nop";
            sec_level = "authPriv";
            auth_protocol = "SHA";
            priv_protocol = "AES";
            auth_password = "\${SNMP_AUTH}";
            priv_password = "\${SNMP_PRIV}";
            agent_host_tag = "source";
            path = [../blobs/monitoring/snmp/mibs];
            tagexclude = ["host"];
            field = [
              {
                oid = "PowerNet-MIB::upsBasicIdentName.0";
                name = "upsId";
                is_tag = true;
              }
              {
                oid = "PowerNet-MIB::upsAdvIdentSkuNumber.0";
                name = "upsModel";
                is_tag = true;
              }
              {
                oid = "PowerNet-MIB::upsBasicBatteryStatus.0";
                name = "ups_battery_status";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecBatteryCapacity.0";
                name = "ups_battery_current_capacity";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecBatteryTemperature.0";
                name = "ups_battery_current_temp";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecBatteryActualVoltage.0";
                name = "ups_battery_current_volt";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsBasicBatteryTimeOnBattery.0";
                name = "ups_time_on_battery";
              }
              {
                oid = "PowerNet-MIB::upsAdvBatteryRunTimeRemaining.0";
                name = "ups_battery_remaining_runtime";
              }
              {
                oid = "PowerNet-MIB::upsAdvBatteryReplaceIndicator.0";
                name = "ups_battery_replace_indicator";
              }
              {
                oid = "PowerNet-MIB::upsAdvInputLineFailCause.0";
                name = "ups_last_reason_to_battery";
              }
              {
                oid = "PowerNet-MIB::upsBasicOutputStatus.0";
                name = "ups_output_status";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecInputLineVoltage.0";
                name = "ups_input_volt";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecInputFrequency.0";
                name = "ups_input_freq";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecOutputVoltage.0";
                name = "ups_output_volt";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecOutputCurrent.0";
                name = "ups_output_amp";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecOutputFrequency.0";
                name = "ups_output_freq";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecOutputLoad.0";
                name = "ups_output_load";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecOutputEfficiency.0";
                name = "ups_output_eff";
                conversion = "float(1)";
              }
              {
                oid = "PowerNet-MIB::upsAdvOutputActivePower.0";
                name = "ups_output_power";
              }
              {
                oid = "PowerNet-MIB::upsHighPrecOutputEnergyUsage.0";
                name = "ups_total_out_energy";
                conversion = "float(2)";
              }
            ];
          }
          # core switch
          {
            agents = ["udp://10.88.0.4:161"];
            version = 3;
            sec_name = "nop";
            sec_level = "authPriv";
            auth_protocol = "SHA";
            priv_protocol = "AES";
            auth_password = "\${SNMP_AUTH}";
            priv_password = "\${SNMP_PRIV}";
            agent_host_tag = "source";
            path = [../blobs/monitoring/snmp/mibs];
            tagexclude = ["host"];
            field = [
              {
                oid = "SNMPv2-MIB::sysName.0";
                name = "switch";
                is_tag = true;
              }
              {
                oid = "SNMP-FRAMEWORK-MIB::snmpEngineTime.0";
                name = "uptime";
              }
              {
                oid = "CISCO-ENVMON-MIB::ciscoEnvMonTemperatureStatusValue.1013";
                name = "temperature";
              }
              {
                oid = "CISCO-PROCESS-MIB::cpmCPUTotal1minRev.19";
                name = "cpuOneMin";
              }
            ];
            table = [
              {
                name = "interfaces";
                inherit_tags = ["switch"];
                field = [
                  {
                    oid = "IF-MIB::ifDescr";
                    name = "ifName";
                    is_tag = true;
                  }
                  {oid = "IF-MIB::ifOperStatus";}
                  {oid = "IF-MIB::ifHCInOctets";}
                  {oid = "IF-MIB::ifHCOutOctets";}
                  {oid = "IF-MIB::ifHCInUcastPkts";}
                  {oid = "IF-MIB::ifHCInMulticastPkts";}
                  {oid = "IF-MIB::ifHCInBroadcastPkts";}
                  {oid = "IF-MIB::ifHCOutUcastPkts";}
                  {oid = "IF-MIB::ifHCOutMulticastPkts";}
                  {oid = "IF-MIB::ifHCOutBroadcastPkts";}
                ];
              }
            ];
            tagdrop = {
              ifName = ["Vlan*" "unrouted*" "AppG*" "Gigabit*" "Bluetooth*" "Twenty*" "Forty*" "Stack*" "Null0"];
            };
          }
          # core firewall
          {
            agents = ["udp://10.88.0.5:161"];
            version = 3;
            sec_name = "nop";
            sec_level = "authPriv";
            auth_protocol = "SHA256";
            priv_protocol = "AES";
            auth_password = "\${SNMP_AUTH}";
            priv_password = "\${SNMP_PRIV}";
            agent_host_tag = "source";
            path = [../blobs/monitoring/snmp/mibs];
            tagexclude = ["host"];
            field = [
              {
                oid = "SNMPv2-MIB::sysName.0";
                name = "firewall";
                is_tag = true;
              }
              {
                oid = "HOST-RESOURCES-MIB::hrSystemUptime.0";
                name = "uptime";
              }
              {
                oid = "JUNIPER-MIB::jnxOperatingCPU.9.1.0.0";
                name = "cpuMgmtLoad";
              }
              {
                oid = "JUNIPER-CHASSIS-FWDD-MIB::jnxFwddRtThreadsCPUUsage";
                name = "cpuDataLoad";
              }
              {
                oid = "JUNIPER-MIB::jnxOperatingTemp.9.1.0.0";
                name = "cpuTemperature";
              }
              {
                oid = "JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringCurrentTotalSession.0";
                name = "sessionsActive";
              }
            ];
            table = [
              {
                name = "interfaces";
                inherit_tags = ["firewall"];
                field = [
                  {
                    oid = "IF-MIB::ifName";
                    is_tag = true;
                  }
                  {oid = "IF-MIB::ifOperStatus";}
                  {oid = "JUNIPER-IF-MIB::ifHCIn1SecOctets";}
                  {oid = "JUNIPER-IF-MIB::ifHCOut1SecOctets";}
                  {oid = "JUNIPER-IF-MIB::ifIn1SecPkts";}
                  {oid = "JUNIPER-IF-MIB::ifOut1SecPkts";}
                ];
              }
            ];
            tagdrop = {
              ifName = ["*.32767" "gr-*" "ip-*" "lsq-*" "lt-0/0/0" "mt-*" "sp-*" "esi" "fti*" "fxp*" "gre*" "ipip*" "irb*" "jsrv*" "lo0*" "lsi*" "mtun*" "pim*" "pp*" "rbeb*" "tap*" "vtep*"];
            };
          }
          # server firewalls
          {
            agents = ["udp://10.88.0.7:161" "udp://10.88.0.8:161"];
            interval = "15s";
            version = 3;
            sec_name = "nop";
            sec_level = "authPriv";
            auth_protocol = "SHA256";
            priv_protocol = "AES";
            auth_password = "\${SNMP_AUTH}";
            priv_password = "\${SNMP_PRIV}";
            agent_host_tag = "source";
            path = [../blobs/monitoring/snmp/mibs];
            tagexclude = ["host"];
            field = [
              {
                oid = "SNMPv2-MIB::sysName.0";
                name = "firewall";
                is_tag = true;
              }
              {
                oid = "HOST-RESOURCES-MIB::hrSystemUptime.0";
                name = "uptime";
              }
              {
                oid = "HOST-RESOURCES-MIB::hrProcessorLoad.1";
                name = "cpuMgmtLoad";
              }
              {
                oid = "HOST-RESOURCES-MIB::hrProcessorLoad.2";
                name = "cpuDataLoad";
              }
              {
                oid = ".1.3.6.1.2.1.99.1.1.1.4.9";
                name = "cpuTemperature";
              }
              {
                # oid = "PAN-COMMON-MIB::panSessionActive.0";
                oid = "1.3.6.1.4.1.25461.2.1.2.3.3.0";
                name = "sessionsActive";
              }
              {
                # oid = "PAN-COMMON-MIB::panSessionActiveTcp.0";
                oid = "1.3.6.1.4.1.25461.2.1.2.3.4.0";
                name = "sessionsActiveTcp";
              }
              {
                # oid = "PAN-COMMON-MIB::panSessionActiveUdp.0";
                oid = "1.3.6.1.4.1.25461.2.1.2.3.5.0";
                name = "sessionsActiveUdp";
              }
              {
                # oid = "PAN-COMMON-MIB::panSessionActiveICMP.0";
                oid = "1.3.6.1.4.1.25461.2.1.2.3.6.0";
                name = "sessionsActiveICMP";
              }
            ];
            table = [
              {
                name = "interfaces";
                inherit_tags = ["firewall"];
                field = [
                  {
                    oid = "IF-MIB::ifName";
                    is_tag = true;
                  }
                  {oid = "IF-MIB::ifOperStatus";}
                  {oid = "IF-MIB::ifHCInOctets";}
                  {oid = "IF-MIB::ifHCOutOctets";}
                  {oid = "IF-MIB::ifHCInUcastPkts";}
                  {oid = "IF-MIB::ifHCInMulticastPkts";}
                  {oid = "IF-MIB::ifHCInBroadcastPkts";}
                  {oid = "IF-MIB::ifHCOutUcastPkts";}
                  {oid = "IF-MIB::ifHCOutMulticastPkts";}
                  {oid = "IF-MIB::ifHCOutBroadcastPkts";}
                ];
              }
            ];
            tagdrop = {
              ifName = ["vlan*" "loopback*" "tunnel" "vxlan*"];
            };
          }
          # nas
          {
            agents = ["udp://10.81.70.1:161" "udp://10.81.70.2:161"];
            version = 3;
            sec_name = "nop";
            sec_level = "authPriv";
            auth_protocol = "SHA";
            priv_protocol = "AES";
            auth_password = "\${SNMP_AUTH}";
            priv_password = "\${SNMP_PRIV}";
            agent_host_tag = "source";
            path = [../blobs/monitoring/snmp/mibs];
            tagexclude = ["host"];
            field = [
              {
                oid = "SNMPv2-MIB::sysName.0";
                name = "nas";
                is_tag = true;
              }
              {
                oid = "SNMP-FRAMEWORK-MIB::snmpEngineTime.0";
                name = "uptime";
              }
              {
                oid = "SYNOLOGY-SYSTEM-MIB::systemStatus.0";
                name = "nas_status";
              }
              {
                oid = "SYNOLOGY-SYSTEM-MIB::temperature.0";
                name = "temperature";
              }
            ];
            table = [
              {
                name = "interfaces";
                inherit_tags = ["nas"];
                field = [
                  {
                    oid = "IF-MIB::ifName";
                    is_tag = true;
                  }
                  {oid = "IF-MIB::ifOperStatus";}
                  {oid = "IF-MIB::ifHCInOctets";}
                  {oid = "IF-MIB::ifHCOutOctets";}
                ];
              }
              {
                name = "disks";
                inherit_tags = ["nas"];
                field = [
                  {
                    oid = "SYNOLOGY-DISK-MIB::diskName";
                    is_tag = true;
                  }
                  {
                    oid = "SYNOLOGY-DISK-MIB::diskStatus";
                    name = "diskLogicalStatus";
                  }
                  {oid = "SYNOLOGY-DISK-MIB::diskHealthStatus";}
                  {oid = "SYNOLOGY-DISK-MIB::diskTemperature";}
                  {oid = "SYNOLOGY-DISK-MIB::diskBadSector";}
                ];
              }
              {
                name = "volumes";
                inherit_tags = ["nas"];
                field = [
                  {
                    oid = "SYNOLOGY-RAID-MIB::raidName";
                    is_tag = true;
                  }
                  {oid = "SYNOLOGY-RAID-MIB::raidStatus";}
                  {oid = "SYNOLOGY-RAID-MIB::raidFreeSize";}
                  {oid = "SYNOLOGY-RAID-MIB::raidTotalSize";}
                ];
              }
              {
                name = "volumeio";
                inherit_tags = ["nas"];
                field = [
                  {
                    oid = "SYNOLOGY-SPACEIO-MIB::spaceIODevice";
                    is_tag = true;
                  }
                  {oid = "SYNOLOGY-SPACEIO-MIB::spaceIOReads";}
                  {oid = "SYNOLOGY-SPACEIO-MIB::spaceIOWrites";}
                  {oid = "SYNOLOGY-SPACEIO-MIB::spaceIONReadX";}
                  {oid = "SYNOLOGY-SPACEIO-MIB::spaceIONWrittenX";}
                ];
              }
            ];
            tagdrop = {
              ifName = ["lo" "sit0"];
            };
          }
        ];
        vsphere = [
          {
            tagexclude = ["moid" "source" "host"];
            interval = "20s";
            vcenters = ["https://rmnmvvmvcs.snct.rmntn.net/sdk"];
            username = "monitoring@vsphere.local";
            password = "\${VSPHERE_PW}";

            insecure_skip_verify = true;
            ip_addresses = ["ipv4"];

            vm_metric_exclude = ["*"];
            host_metric_include = [
              "cpu.latency.average"
              "cpu.readiness.average"
              "cpu.usage.average"
              "cpu.usagemhz.average"
              "cpu.totalCapacity.average"
              "mem.consumed.average"
              "mem.latency.average"
              "mem.swapout.average"
              "mem.vmmemctl.average"
              "mem.state.latest"
              "mem.usage.average"
              "disk.commandsAborted.summation"
              "disk.commandsAveraged.average"
              "disk.deviceReadLatency.average"
              "disk.deviceWriteLatency.average"
              "disk.kernelLatency.average"
              "disk.numberReadAveraged.average"
              "disk.numberWriteAveraged.average"
              "disk.read.average"
              "disk.write.average"
              "net.bytesTx.average"
              "net.bytesRx.average"
              "sys.uptime.latest"
            ];
            datastore_metric_exclude = ["*"];
            cluster_metric_exclude = ["*"];
            resource_pool_metric_exclude = ["*"];
            datacenter_metric_exclude = ["*"];
          }
        ];
      };
      processors.starlark = [
        {
          source = ''
            '''
            def apply(metric):
              if metric.name == "vsphere_host_cpu":
                if metric.tags["cpu"] != "instance-total":
                  metric.fields.clear()
              return metric
            '''
          '';
        }
      ];
      outputs = {
        influxdb = [
          {
            urls = ["http://127.0.0.1:8428"];
            exclude_database_tag = true;
            skip_database_creation = true;
          }
        ];
      };
    };
  };
}
