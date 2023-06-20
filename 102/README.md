# PQC 102 - How to implement quantum-resistant services

_It’s time to get hands-on with some real post-quantum crypto! In this video we explore the Open Quantum Safe project and browse to some websites running quantum-resistant crypto algorithms using a special build of Chrome. We then see how easy it is to create our own webserver running the Kyber and Dilithium post-quantum algorithms._

**The video version can be found here: https://youtu.be/5SN60Ptephs**

[![Click to play](https://img.youtube.com/vi/5SN60Ptephs/0.jpg)](https://www.youtube.com/watch?v=5SN60Ptephs)

## Intro

In the first video in this series we examined the threat that quantum computers pose to the encryption methods we used today, and took a took a brief look at some of the new cryptographic algorithms that could help keep us secure in the age of quantum computing. But how easy is it to apply them in practice? Hi, I’m Andy, and in this video I’ll be demonstrating some real-world post-quantum crypto, and showing how you too can configure it on your own services.

A quick word of warning from the outset. Yes, you can absolutely run post-quantum crypto today, and of course I recommend you give this a try to gain some practical experience. But that doesn’t mean you should run off and convert all your production services to post-quantum crypto! The implementation we’ll be using here is specifically intended for development and prototyping, and is NOT recommended for production use!

That said, let’s get stuck in!

## The Open Quantum Safe Project

Much of the hard work around implementing post-quantum crypto has already been done for us by the wonderful team contributing towards the Open Quantum Safe project. They’ve implemented a huge range of different algorithms into a single library – LIBOQS – including those that have been selected by NIST for standardisation.

Just having a crypto implementation is not enough though. We need a way of integrating that into the applications and services we use today, such as our web servers and web browsers. Again the Open Quantum Safe team have done the heavy lifting for us, and have built their LIBOQS code into forks of OpenSSL and BoringSSL – the crypto libraries that power a significant portion of software in use today. And if that’s not enough, they’ve also provided a selection of docker images for common software to enable us to get experimenting with PQC in just a few commands, and have made scores of test servers publicly available for experimentation. Each of these individual servers support a different combination of post-quantum digital signature scheme and key exchange scheme. Accessing any of these using the standard version of Chrome or Firefox throws up a connection error. This is because whilst these servers run by the OQS project are configured to establish a TLS session using post-quantum algorithms, those algorithms aren’t yet built in to our mainstream web browsers.

## PQC web browser (Chromium)

But of course OQS also provide a PQC-enabled version of Chrome available for download from their website. Once downloaded we can extract using ‘tar’, and launch. Using it we can then access those PQC-enabled test websites at test.openquantumsafe.org. Note that this pre-compiled build of Chrome doesn’t support every single variant of every single algorithm out-of-the-box, and there’s a separate sub-page which lists only those which it does support. Accessing one with our PQC-enabled Chrome shows us a simple site confirming the connection has been successful.

It's... a little underwhelming really. Apart from a warning due to the use of a self-signed certificate, this looks no different to normal web browsing. Is this really using one of those state-of-the-art quantum-safe algorithms? We’ll dig deeper by examining some packet captures a little later in this video, but the fact that nothing changes from an end-user’s perspective is great! The TLS layer abstracts away much of the complexity, providing us with a much easier migration path to implementing post-quantum cryptography.

## PQC web server (Nginx)

However, we do need to uncover some of that hidden complexity when it comes to creating our own quantum-resistant services, so let’s do that now. For starters, lets quickly recap the several different cryptographic components at play in TLS: the Key Exchange scheme, the Digital Signature used to authenticate the server, and the cipher suite used for the session. Each of these has a different cryptographic configuration which we need to consider as part of our setup.

![image](https://github.com/rot169/pqc/assets/59445582/8a9df444-1912-4444-8e58-af433b2e2cd4)

We first need to create a chain of trust for the certificate used to authenticate our server. Here I’m using the OQS-enabled version of openssl to create a self-signed certificate to act as a certificate authority.

```
mkdir server-pki && cd server-pki
sudo docker run -v `pwd`:/opt/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey rsa -keyout /opt/tmp/CA.key -out /opt/tmp/CA.crt -nodes -subj "/CN=Andy's Post-Quantum CA" -days 365
```

Next, we’ll create another key for our web server. In a pre-quantum world we’d choose either an elliptic curve or RSA signature scheme for our certificate, but as we want to be quantum-safe I’m choosing a variant of the Dilithium algorithm.

```
sudo docker run -v `pwd`:/opt/tmp -it openquantumsafe/curl openssl req -new -newkey dilithium3 -keyout /opt/tmp/server.key -out /opt/tmp/server.csr -nodes -subj "/CN=localhost“-addext "subjectAltName = DNS:localhost"
```

Then finally, sign the server’s certificate with our CA. 

```
sudo docker run -v `pwd`:/opt/tmp -it openquantumsafe/curl openssl x509 -req -in /opt/tmp/server.csr -out /opt/tmp/server.crt -CA /opt/tmp/CA.crt -CAkey /opt/tmp/CA.key -CAcreateserial -days 365 -copy_extensions copy
```

Next, the Key Exchange scheme. This is defined in the web server configuration, so here I’m extracting the default nginx config file that comes pre-packaged in the OQS nginx docker container so that we can modify it.

```
cd ..
mkdir server-conf && cd server-conf
sudo docker run -it openquantumsafe/nginx cat /opt/nginx/nginx-conf/nginx.conf > nginx.conf
```

Pre-quantum we’d use a Diffie-Hellman key exchange either based on RSA or elliptic curves, and the `ssl_ecdh_curve` config property would define the specific elliptic curves to accept. In the quantum-resistant world, we repurpose this field to specify our supported key exchange methods here. Whilst we could specify several different options here to allow for the client and server to negotiate a mutually acceptable key exchange mechanism, in this case we’re just specifying one specific variant of the Kyber algorithm. 

```
sudo nano nginx.conf    # Add: ssl_ecdh_curve p256_kyber90s512;
```

The third part of the cryptographic configuration, the session cipher suite, can also be set in this same config file. Session encryption is based on a symmetric algorithm, and recall from the previous video that our symmetric crypto schemes such as AES are not considered to be at significant threat from being broken by quantum computers. So we don’t include any specific configuration option in order to accept the defaults. 

With all that in place we’re now ready to start up the web server container, being sure to map in the folders containing our crypto keys and config file.

```
cd ..
sudo docker run --rm -p 4433:4433 -v `pwd`/server-pki:/opt/nginx/pki -v `pwd`/server-conf:/opt/nginx/nginx-conf openquantumsafe/nginx
```

We can test it by heading back to Chrome, but we need to first add our test Certificate Authority as a trusted root so as to avoid certificate warnings. With that in place we can navigate to the site – running on localhost port 4433 – and see the default nginx placeholder page appearing like normal. After all that work, again nothing looks any different to browsing with our traditional cryptographic algorithms.

## PQC Analysis (Wireshark)

So by now you’re probably wanting to see some hard proof that we’ve actually witnessed post-quantum crypto in action here, so let’s fire up Wireshark and pick through some packets. We’ll be using a version from Open Quantum Safe which includes updated packet dissectors which are PQC-aware. In order to capture packets on this system I need to run as root via sudo, so I’m using the `xhost` command here to grant root processes access to my GUI session. With that done we can launch Wireshark from the open quantum safe Docker image with the following command.

```
xhost +si:localuser:root
sudo docker run --net=host --privileged --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" openquantumsafe/wireshark
```

With Wireshark running in the background we can switch over to our OQS Chrome browser and hit the refresh button on the same test.openquantumsafe.org service… and our own PQC-enabled nginx webserver.

Back in Wireshark we can conclude the capture and get digging. First, filtering for only TLS traffic by using the ‘tls’ filter. We can drill-down further to just the first TLS communication associated with test.openquantusafe.net by applying a port-based filter; in this case the particular test service we accessed was on port 6242.

The ClientHello message is sent by the client to the server to initiate a TLS session. We can expand the dissection to see various details, but for us the key parameter here is ‘supported_groups’. This includes a list of the elliptic curves which the client support for key exchange, and, as we discussed previously, this field is repurposed for post-quantum key exchange, so we can also see which quantum-resistant key exchange algorithms the client supports. Note there’s several ‘unknown’ items here which indicate a mismatch between the quantum-resistant algorithms supported by the Chrome browser, and the algorithms that this version of wireshark can recognise.

The server compares this list with its own configuration, selects one, and notifies the client through the ServerHello message – and specifically through the ‘key_share’ extension. Here we can see the server has selected a variant of frodo.

Note that the Frodo algorithm was dropped by NIST after making it through to the 3rd round of the selection process, so is not an algorithm you’re likely to see in practical use.

We can add this property to our packet display through right-clicking, and selecting “apply as column”. This allows us to speed up the process of examining our second TLS connection to our own nginx webserver. We just need to change the filter to only include packets to port 4433… and we can see in the ServerHello response that the kyber variant we’d specified in our config file has indeed been selected for this communication.

## PQC Analysis (Chome / OpenSSL)

Ok so we’ve successfully proven that the Key Exchange Mechanism for these connections did indeed use post-quantum algorithms… but that’s only one element of our post-quantum config. What about the digital signature algorithm used to prove the server’s identity? This is stored within the server’s certificate, and is something we can’t carve out of this packet capture as the communication is TLS1.3, and under TLS1.3 the server certificate is encrypted.

We can examine the certificate via Chrome, however. The algorithm should be listed in “Subject Public Key Algorithm” field, but Chrome is only showing a placeholder reference number as this part of Chrome is not yet fully PQC-aware. To properly examine the certificate we must first export it. We can then use our PQC-aware version of openssl to decode it with the following command.
```
sudo docker run -v `pwd`:/opt/tmp -it openquantumsafe/curl openssl x509 -in /opt/tmp/test.openquantumsafe.org.crt -text 
```
Here we can see that the signature algorithm for the particular openquantumsafe test server we accessed earlier is indeed dilithium3.

## Wrap-up

So there you have it – post-quantum security in action… even if it doesn’t look any different from an end-users perspective!

The keen-eyed crypto bods amongst you may have spotted something intriguing about some of the cipher names we observed in this video… the prefix of ‘p256’ on several algorithm names. P256 is one of the common curves used in elliptic curve cryptography… but if ECC is supposedly broken by quantum computers, what’s it doing showing up here in post-quantum crypto? We’ll cover this in more detail in the next video, along with a broader discussion on strategy and approach to adopting post-quantum crypto.
