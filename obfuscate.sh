#!/bin/bash

echo "Start obfuscate"
cd clients
	
mono "ASASMAlter_mac.exe" "client_release.swf";
	
echo "done"
