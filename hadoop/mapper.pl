
#
# mapper.pl
#
# Scans a Common Crawl WAT archive and extracts the links
#
# Input:
#    - Contains URL 3 time (1. HTTP request header information, 2. response, 3. 
# Output:
#   
# 
# 

use Digest::MD5 qw(md5 md5_hex md5_base64);

sub get_TLD {
    my $url = shift;
    
    $url =~ s/https//g;
    $url =~ s/http//g;
    $url =~ s!://!!g;
    $url =~ s!//!!g;
    $url =~ s!/.*!!g;
    
    @url_array = split(/\./, $url);
    my $arrSize = @url_array;
    
    return $url_array[$arrSize-2] . "." . $url_array[$arrSize-1] ;    
}

while (<>) {

    # remove trailing \n
    # chomp;
    $_ =~ tr/\x{d}\x{a}//d;
    
    # print "\nINPUT: '" . $_ . "'";
    
    # let's handle metadata
    if ($_ eq "WARC-Type: metadata") {

        # this is what the header will look like
        # WARC-Type: metadata
        # WARC-Target-URI: http://0-search.informit.com.au.alpha2.latrobe.edu.au/search;res=PERIND
        # WARC-Date: 2015-06-30T03:25:07Z
        # WARC-Record-ID: <urn:uuid:754db613-1ce2-42b5-a6aa-0dd4a7f42247>
        # WARC-Refers-To: <urn:uuid:1b0c2eaa-4780-4a83-9811-9350dac229ff>
        # Content-Type: application/json
        # Content-Length: 1457
        # <empty line>
        # <JSON-Data>
        #  print "\nWorking on Metadata entry\n";
    
        
        $targetURI = readline(*STDIN); # print($targetURI); # Line 1    WARC-Target-URI
        $line = readline(*STDIN);  # print($line); # Line 2 - ignore
        $line = readline(*STDIN);  # print($line); # Line 3 - ignore
        $line = readline(*STDIN);  # print($line); # Line 4 - ignore
        $line = readline(*STDIN);  # print($line); # Line 5  - ignore  
        $line = readline(*STDIN);  # print($line); # Line 6  - ignore  
        $line = readline(*STDIN);  # print($line); # Line 7 - ignore   
        $jsonData = readline(*STDIN); # print($jsonData); # Line 8 - JSON-Data

        # only continue if we are working on a "response" entry
        if (index($jsonData, "WARC-Type":"response") == -1) { next; }
        
        $srcURI = $targetURI;
        $srcURI =~ s/WARC-Target-URI: //g;
        $srcURI =~ s/\n//g;
        $srcURI =~ s/\x{d}//g;
        # $hash = md5_hex($srcURI);             
        $tld = get_TLD($srcURI);
        $hash = $tld;
        print "$hash 1URL $tld $srcURI\n";
        #print "$hash $tld\n";
                
        # Let's see if we can avoid to parse the JSON
        # insert newlines into JSON                              
        $jsonData =~ s!}]!}]\n!g;   # add a line break after each "}]"
        $jsonData =~ s!},!},\n!g;   # add a line break after each "},"
        $jsonData =~ s!{!\n{!g;   # add a line break before each "{"
        
                
        # we are interested in the SCRIPT@/src entries
        #$jsonData =~ s!SCRIPT@/src!\nGET-SCRIPT!g;
        #$jsonData =~ s!IMG@/src!GET-IMG@/src!g;
        #$jsonData =~ s!path":"!\nGET-path:"/src!g;
        
        @lines = split(/\n/, $jsonData);
        @paths = grep(/path/, @lines);
        @paths = grep(!/href/, @paths);   # delete all hrefs
        @paths = grep(!/"Set-Cookie"/, @paths);   # delete all "Set-Cookie" things that contain a path
        
        #@paths = @lines;
        # init empty results array
        my @results = qw();

        foreach (@paths) {
        
            # remove the "alt" tags in the 
            $_ =~ s!"alt":".*?",!!g; 
            if ($_ =~ /"url":"(.*?)"/) {
                #print $1 . "\n";
                $url = $1;
                $url =~ s!\?.*!!g;      # remove query parameters
                
                $url =~ s!https:!!g;    # remove protocol parameters
                $url =~ s!http:!!g;     # remove protocol parameters
                
                # check if we have a root URL
                if (substr($url,0,2) eq "//") {                
   
                    # check if we have a different domain
                    # my $url_TLD = get_TLD($url);
                    if ($tld ne get_TLD($url)) {
                    
                        # root URL AND different domain -> print!
                        $path = $_;
                        $path =~ /"path":"(.*?)"/;
                        
                        $uTLD = get_TLD($url);
                        if ($uTLD eq "googleapis.com") { $uTLD = "google.com" }
                        if ($uTLD eq "googletagmanager.com") { $uTLD = "google.com" }
                        if ($uTLD eq "google.com") { $uTLD = "google.com" }
                        if ($uTLD eq "googlesyndication.com") { $uTLD = "google.com" }
                        if ($uTLD eq "googleadservices.com") { $uTLD = "google.com" }
                        if ($uTLD eq "google-analytics.com") { $uTLD = "google.com" }
                        if ($uTLD eq "youtube.com") { $uTLD = "google.com" }                        
                        if ($uTLD eq "googletagservices.com") { $uTLD = "google.com" }                        
                        if ($uTLD eq "doubleclick.net") { $uTLD = "google.com" }                                                
                        
                        if ($uTLD eq "facebook.net") { $uTLD = "facebook.com" }                                                
                        
                        # push(@results, "$hash LNK " . get_TLD($url) . " $1 $url \n");
                        push(@results, "$hash 2LNK $uTLD\n");
                        #print $hash . " " . get_TLD($url) ."\n";                       
                    } # if tld
                } #  if substr
            } 
        } # foreach paths
       
        @results = sort @results;
       
        $output = join( "" , @results);        
      
        print($output);

        
        #print("\nDONEDONEDONE--------------------------\n");
        #print("\n");
    } # eq metadata
} # while
