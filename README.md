# LernCloud Terraform Module fuer Promox


Dieses Repository ist Bestandteil vom [LernCloud](https://github.com/mc-b/lerncloud) Projekt.

Proxmox VE (Proxmox Virtual Environment; kurz PVE) ist eine auf Debian basierende Open-Source-Virtualisierungsplattform zum Betrieb von virtuellen Maschinen mit einem Webinterface zur Einrichtung und Steuerung von x86-Virtualisierungen. Die Umgebung basiert auf QEMU mit der Kernel-based Virtual Machine (KVM). PVE bietet neben dem Betrieb von klassischen virtuellen Maschinen (Gastsystemen), die auch den Einsatz von Virtual Appliances erlauben, auch LinuX Containers (LXC) an.

Cloud-init Support ist zwar vorhanden, dazu müssen sich aber alle Cloud-init Scripts im  `/var/lib/vz/snippets` Verzeichnis befinden. Das auf jeder Installieren Maschine innerhalb eines Cluster. Zusätzlich muss eine Cloud-init VM Template erzeugt werden.

### Installation und User anlegen

Installation

    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor >/usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bullseye main" >/etc/apt/sources.list.d/hashicorp.list
    apt update && apt install terraform

ProxMox User, für Zugriff via Terraform anlegen, Password ggf. ändern

    pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.PowerMgmt"
    pveum user add terraform-prov@pve --password insecure
    pveum aclmod / -user terraform-prov@pve -role TerraformProv
    
**Besser**: API-Key statt Password verwenden, siehe [hier](https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/).    

### Cloud-init VM Template

Es wird eine VM anhand eines Cloud-Image erstellt, Guest Tools installiert und als Template zur Verfügung gestellt

    mkdir -p /var/lib/vz/cloudimg 
    wget -O /var/lib/vz/cloudimg/jammy-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
    apt update -y && apt install libguestfs-tools -y
    virt-customize -a /var/lib/vz/cloudimg/jammy-server-cloudimg-amd64.img --install qemu-guest-agent    

    qm create 10000 --memory 4096 --cores 2 --name "ubuntu-2204-cloudinit-template" --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
    qm set 10000 --scsi0 local-lvm:0,import-from=/var/lib/vz/cloudimg/jammy-server-cloudimg-amd64.img
    
    qm set 10000 --ide2 local-lvm:cloudinit
    qm set 10000 --boot order=scsi0
    qm set 10000 --serial0 socket --vga serial0
    qm resize 10000 scsi0 +30G
    
    qm set 10000 --ciuser ubuntu
    qm set 10000 --sshkeys /etc/pve/priv/authorized_keys
    
    qm template 10000 
    
### Cloud-init Beispiele

Snippets Verzeichnis anlegen und ein paar Cloud-init Scripte aufbereiten als Snippets.

    mkdir -p /var/lib/vz/snippets
    
    wget -O /var/lib/vz/snippets/base.yaml https://github.com/mc-b/lerncloud/raw/main/modules/base.yaml
    wget -O /var/lib/vz/snippets/microk8smaster.yaml https://github.com/mc-b/lerncloud/raw/main/modules/microk8smaster.yaml
    wget -O /var/lib/vz/snippets/microk8sworker.yaml https://github.com/mc-b/lerncloud/raw/main/modules/microk8sworker.yaml    
    
### Tips und Tricks

Im Verzeichnis `examples` befindet sich eine funktionsfähige Terraform Konfiguration. Diese kann wie folgt geholt werden:

    git clone https://github.com/mc-b/terraform-lerncloud-proxmox
    cd terraform-lerncloud-proxmox/examples
    terraform init

Ändern der Target-Node

    sed -i 's/pve-01/pve-02/g' $(find . -name "variables.tf")
    
Ändern des URLs für den Zugriff auf Proxmox

    sed -i 's/192.168.1.196/<mein DNS oder IP>/g' $(find . -name "variables.tf")        

Weitere Einstellungen, siehe Datei `variables.tf`.

### Metadata und Vendordata

Wie in der [Cloud-init Dokumentation](https://cloudinit.readthedocs.io/en/23.1.1/reference/datasources/nocloud.html) beschrieben, können auch Metadaten, wie Hostname etc. via Cloud-init übergeben werden.

So können Standard Cloud-init Script zusätzlich konfigurbar gemacht werden, z.B. Mounten eines NFS-Shares wenn das Cloud-init Script auf unterschiedlichen Proxmox System ausgeführt wird.

Metadata und Vendordata werden als Dateien übergeben und müssen im `snippets` Verzeichnis abgelegt werden.

Beispiel in `main.tf`  

      cicustom = "user=local:snippets/${var.userdata},meta=local:snippets/meta.yaml,vendor=local:snippets/vendor.yaml"
      
Für Metadata sind nur die [hier](https://cloudinit.readthedocs.io/en/23.1.1/reference/datasources/nocloud.html) beschriebenen Einträge möglich.

Für Vendordata scheint YAML als Format erwünscht. Grundsätzlich kann alles übergeben werden. Die Datei steht, in der VM, als `/var/lib/cloud/instance/vendor-data.txt` zur Verfügung.    

- - -

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />Dieses Werk ist lizenziert unter einer <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Namensnennung 4.0 International Lizenz</a>.

Copyright (C) mc-b.ch, Marcel Bernet

*Verlinkte Scripte können andere Copyrights beinhalten!*