# PQC 103 - Strategic considerations for post-quantum crypto migration
_In the final part of this three-part series we examine the strategic considerations for an effective post-quantum cryptography migration. Whilst the risk of quantum may be low today, migrating is a multi year journey, and there’s some simple steps we can (and should!) start thinking about today to make that transition easier._

So far in this series we’ve explored the case for post-quantum cryptography, and seen how we can convert our current quantum-vulnerable apps to bleeding-edge quantum-resistant algorithms using experimental libraries such as LIBOQS. But whilst it may be technically possible to operate post-quantum security today, deployment outside of testlab environments needs some careful consideration and planning.

Hi, I’m Andy, and in this video we’ll be discussing the key considerations for real-world PQC deployment, including the items you should be building into long term roadmaps, and the steps you should start taking today.

## When to act

We mentioned in the first video that, as I record this in mid-2023, there’s no known quantum computer sufficiently capable of running Shor’s algorithm on the size of numbers required to break any practical cryptographic implementation, and such a machine is unlikely to exist for at least several years.

Research and development continue however, to create more advanced quantum computers that can run Shor’s algorithm at the scale required. And there’s also active research into improving the algorithms used to crack crypto so as to reduce the quantum requirements, and hence run on a simpler quantum computer.

When will these two factors collide to actually break our current cryptosystems? Well, that’s anyone’s guess! And it’s not as simple as this graphic suggests – there is no definitive ‘finish line’ because that depends on how we define whether a given cryptosystem is broken or not. I think we’d all agree that if an attacker can crack a given algorithm in a few minutes then that’d be considered broken. But what if it took several weeks? Or a few months? Or a couple of years? Some of these periods may make it impractical for an attacker who’s looking to actively intercept and interfere with an encrypted session in real-time, but might be just fine for an attacker who’s managed to capture some particularly sensitive data and still sees value in decrypting it years later – what’s known as a ‘store now, decrypt later’ attack. 

And, however powerful quantum computers might become in the future, we’re unlikely to see a ‘big bang’ appearance of a device that can crack the algorithms we use today in mere seconds; it’ll be something that emerges over time. And even after such a device become a reality, it’s likely to stay in the hands of nation states for a considerable period, so it doesn’t mean it’ll necessarily be available to the particular threat actors who are targeting you or your organisation.

## Early-adopter risk

It can therefore be tempting to dismiss the security threat of quantum computing and just kick the can down the road – upgrading crypto systems is no simple task. And being an early adopter of a new cryptosystem could come with some risks of its own. Afterall our traditional algorithms have been tried-and-tested over decades; we know them to be safe against traditional attacks. These new PQC algorithms are relatively very new; are we really sure that they’re safe? We’ve already seen one NIST PQC candidate – the SIKE algorithm – suffer from a fatal design flaw whereby it could be broken by traditional computation, and this was only discovered very late in the selection process. It’s conceivable that a similar vulnerability is discovered in one of our other PQC algorithms after we’ve migrated. So maybe we’re better off sticking with our traditional algorithms for a few more years, and only start the migration when quantum attacks become more likely. This would give the community a bit more time to assess the PQC algorithms for any weaknesses.

This is certainly a very valid strategy, and the one that most organisations will realistically adopt, but it’s position that needs to be regularly reassessed to ensure it’s still meeting the appropriate risk balance, and that organisations are still allowing themselves enough time to undertake migration activities - acknowledging that making all our application and services PQC-safe will take many many years.

## Crypto-inventory

Understanding the size and scale of the PQC migration challenge is a crucial input into this regular reassessment. And that’s the purpose of having a cryptographic inventory – knowing what cryptographic libraries, algorithms and keys are used by which systems and where. Now I’ll admit that inventory is not an exciting task, but it’s fundamental in understanding how big the problem is that we need to address. It also helps highlight which areas to prioritise over others, and inform the specific remediation steps for a given system. For example, many large organisations process and store the bulk of their data in cloud SaaS services like Microsoft’s O365 suite of services, so addressing the PQC challenge in just this one system could mitigate a significant amount of risk. We may not be able to make any practical changes until Microsoft have implemented PQC algorithms such as Kyber and Dilithium in their services, however it’s still useful to understand what the path to mitigation looks like.

It’s a very different story when it comes to internally-developed applications. Here a developer must upgrade the application’s crypto libraries with those which contain PQC algorithms, and then rewrite the app to call the API functions associated with the newer algorithms. Again, knowing what libraries and algorithms are in use today helps to understand how many apps – and therefore how much effort – will be needed to become quantum resistant. Developers can also prioritise apps which store or process more sensitive data. And perhaps we make a risk-based decision to NOT upgrade apps which are of a low criticality, or are legacy systems which are expected to be replaced before quantum computers become sufficiently powerful.

## Automating crypto-inventory

Creating a crypto-inventory doesn’t have to involve a load of manual effort. We can use many of our existing systems, or freely-available open-source solutions, to do a lot of the hard work for us.

Take, for example, what key exchange mechanisms are in use in an environment. We already saw in our previous video that we can observe the list of KEMs supported by a client is included in the TLS Client Hello message, and the KEM selected by the server appears in the Server Hello message. So we can use our existing network security monitoring tools to identify and report on these specific parameters. I created a Zeek script to do exactly that, and here’s the report it produces, showing a list of the TLS servers and clients observed, which KEMs they support – so we can see whether they’re traditional or post-quantum. 

Let look at another example – this time assessing digital signature algorithms. Under modern versions of TLS certificates are exchanged in an encrypted format, so our network monitoring approach won’t reliably work here. But we could use a file scanning approach instead, to search for any certificate files on filesystems, and report back what digital signature algorithms they contain. Here’s an example of a simple script I created to do that, and here’s the report it produces.

Check the video description for a github link to download both these scripts. Whilst they probably won’t create a 100% complete cryptographic inventory for your environments, they’re there to demonstrate a point, and could at least help cover of some of the most common cryptographic assets.

## Crypto-inventory for non-quantum threats

A cryptographic inventory doesn’t just help us prepare for PQC remediation. That same dataset can be invaluable when responding to non-quantum attacks on our cryptosystems too. Take, for example, Heartbleed (which affected specific versions of the OpenSSL library) or BEAST (which affected older versions of the TLS protocol). Knowing what cryptographic libraries, algorithms and keys are used by which systems and where, would help us understand how big the risk is to our organisation, and how to prioritise the response. And chances are we’ll discover another one or two similar non-quantum vulnerabilities in our existing cryptosystems before quantum-based attacks become a reality.

## Hybrid cryptography

Organisations who feel particularly exposed to the ‘store now, decrypt later’ risk may find themselves in a difficult position of wanting to move to PQC crypto earlier than most, but also concerned with the possible security risks of these new less-tested algorithms.

Which to choose…?

Why not both?

This is hybrid cryptography. 

With hybrid crypto we’re using both a traditional algorithm AND a PQC algorithm. This way the PQC algorithm provides protection from any future quantum-based attack, and the traditional algorithm provides protection from any as-yet-undiscovered weakness in the PQC algorithm.

We’ve actually already seen hybrid crypto in action in the previous video. The eagle-eyed viewer may have spotted something interesting in the specific variants of the Frodo and Kyber algorithms we implemented. The algorithm names are prefixed with ‘p256’. P256 is one of the common curves used in our traditional elliptic curve crypto. The key exchange in our demo here is protected with BOTH ECC (using the curve P256) and PQC crypto (using a variant of Kyber).

Hybrid crypto provides us with the best of both worlds, but encrypting or signing everything TWICE surely has a performance impact, right? Whilst yes that is true, we saw in our demos that it’s not particularly significant. Afterall we only use these algorithms for key exchange and signing; we still use traditional symmetric crypto for the bulk of our encryption operations.

## Cryptographic agility

If we don’t feel quite ready to adopt PQC algorithms just yet, any new systems we create today will have to continue to use traditional crypto. But they should be created with the knowledge that at some point in the future we’ll want to replace that traditional crypto with PQC crypto. That’s the mindset of cryptographic agility. It’s all about avoiding any design decisions today that would make the PQC transition harder. Instead we try to lay the foundations today that would facilitate a smoother migration.

In practice this means creating well-architected applications that contain a small number of flexible cryptographic routines that are called from across the app, meaning algorithms can easily be changed in just one or two places rather than necessitating a compete rewrite. Having flexible data structures and data formats can also help.

Broader system architecture may also help support cryptographic agility too. Consider a reverse proxy model for a set of web services that are not quantum safe, however the proxy is. Our PQC crypto is offloaded onto the proxy, providing protection across an untrusted network, with only the final link between the proxy and web services left potentially exposed to a quantum-based attack.

## Wrap-up

Hopefully by now you have a good idea of the real risk that quantum computing poses, what options exist to manage that risk, and how to start approaching this multi-year challenge. Do let me know if there’s any areas you want to explore further as I may create some deeper dives into specific topics in the future. But for now, good luck on your post-quantum journey, and I’ll see you next time!



Video Description

