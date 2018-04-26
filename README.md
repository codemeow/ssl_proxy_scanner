# ssl_proxy_scanner
Scan https://sslproxies.org to get working proxy for desired address

# using

    user@host:~$ echo "https://google.com" | base64
    aHR0cHM6Ly9nb29nbGUuY29tCg==
    user@host:~$ ./sslfinder.sh aHR0cHM6Ly9nb29nbGUuY29tCg==
    # filtering list of proxies
    # load list of proxies
    # checking 153.149.168.27:3128
    # connection failed
    # checking 153.149.168.35:3128
    # connection established
    153.149.168.35:3128
