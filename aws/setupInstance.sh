#!/bin/bash

# Setup Instance


# Get the scripts from the repository
cd ~/
rm -rf CommonCrawlResearch
wget https://github.com/SebastianApel/CommonCrawlResearch/archive/master.zip
unzip -o master
rm master.zip
mv CommonCrawlResearch-master/ CommonCrawlResearch
sudo chmod -R a+rx CommonCrawlResearch # quick fix for permissions problems 