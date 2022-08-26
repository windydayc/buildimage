#!/bin/bash

sed -i 's/--controllers=.*$/--controllers=-nodelifecycle,*,bootstrapsigner,tokencleaner/g' /etc/kubernetes/manifests/kube-controller-manager.yaml