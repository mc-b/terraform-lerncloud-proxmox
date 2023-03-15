# LernCloud Terraform Module fuer Promox


Dieses Repository ist Bestandteil vom [LernCloud](https://github.com/mc-b/lerncloud) Projekt.

Proxmox VE (Proxmox Virtual Environment; kurz PVE) ist eine auf Debian basierende Open-Source-Virtualisierungsplattform zum Betrieb von virtuellen Maschinen mit einem Webinterface zur Einrichtung und Steuerung von x86-Virtualisierungen. Die Umgebung basiert auf QEMU mit der Kernel-based Virtual Machine (KVM). PVE bietet neben dem Betrieb von klassischen virtuellen Maschinen (Gastsystemen), die auch den Einsatz von Virtual Appliances erlauben, auch LinuX Containers (LXC) an.

Cloud-init Support ist zwar vorhanden, dazu müssen sich aber alle Cloud-init Scripts im  `/var/lib/vz/snippets` Verzeichnis befinden. Das auf jeder Installieren Maschine innerhalb eines Cluster. Zusätzlich muss eine Cloud-init VM Template erzeugt werden.

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

- - -

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />Dieses Werk ist lizenziert unter einer <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Namensnennung 4.0 International Lizenz</a>.

Copyright (C) mc-b.ch, Marcel Bernet

*Verlinkte Scripte können andere Copyrights beinhalten!*