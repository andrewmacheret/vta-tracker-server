#!/usr/bin/python

import sys
import urllib2
from bs4 import BeautifulSoup

base_url = "http://www.vta.org"
url = base_url + "/getting-around/gtfs-info/data-file"
link_text = "Google Data in .zip Format"

page = urllib2.urlopen(url).read()
soup = BeautifulSoup(page, "html.parser")
href = soup.find_all("a", string=link_text)[0]['href'];

print base_url + href

sys.exit()
