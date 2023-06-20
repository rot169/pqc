# PQC 101 - Demystifying the quantum crypto threat
_Welcome to the first in a series of videos on post quantum cryptography, where we start with a view on the real risk that quantum computing poses today, and an overview of what we as cyber security professionals can do to overcome those risks. We touch on the pros and cons of quantum random number generation, quantum key exchange, and quantum-resistant algorithms selected for standardisation by NIST._

**The video version can be found here: https://youtu.be/TLB9YgHNRBI**

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/TLB9YgHNRBI/0.jpg)](https://www.youtube.com/watch?v=TLB9YgHNRBI)

## Intro

You’ve probably heard that quantum computers will, at some point in the future, break the encryption schemes we use currently use to protect our data and transactions. But how likely is that really… and what can we do to stay safe?

Hi, I’m Andy, and welcome to the first in a series of videos on post quantum cryptography, where we’ll be getting hands-on with post quantum crypto, exploring some actionable steps to initiate now and whole lot more. We kick off with this video looking at the real risk that quantum computing poses today, and an overview of what we as cyber security professionals can do to overcome those risks.

## Quantum Physics

Let’s get some terminology out of the way first, starting with Quantum Physics. This is a vast and challenging field, but luckily for IT and security professionals we really don’t need to concern ourselves with too much detail here. All the complexities of super-positions, entanglement and wave-particle dualities can essentially be boiled down into “things start to behave really weirdly at very small scales”.

## Quantum Computing

And that weirdness can be harnessed to power Quantum Computers. Whereas our classical electronic computers use digital bits to represent data and perform calculations, with each bit having a value of either one or zero, quantum computers use ‘qbits’ which can exist in a super-position of BOTH one and zero at the same time – just like Schrodinger’s famous cat that’s both dead and alive at the same time.

![image](https://github.com/rot169/pqc/assets/59445582/71c2f0c4-1d8f-412e-8fcb-41d00a2781d1)

And if that’s not weird enough, qbits can be entangled with eachother, linking their states together at the quantum level. These properties allow quantum computers to perform some types of calculations far quicker than traditional computers. And the key word there is **SOME** – quantum computers are programmed in a vastly different way to traditional computers, and not all computations can be re-written in a format which can actually take advantage of the power of quantum computing.

## Cracking Crypto with Quantum Computers

One of the computations that CAN be re-written for quantum computers is determining the prime factors of a given number. The specific quantum algorithm for this is known as Shor’s algorithm, created by Peter Shor back in 1994. Now if you’ve spent any time looking at cryptography before, you’ll recognise prime numbers as being a fundamental aspect of some public key cryptosystems such as RSA. The fact that that classical computers cannot calculate prime factors in an efficient way is exactly what makes RSA cryptographically strong. But this strength could be shattered by a quantum computer which can calculate prime factors exponentially faster. And it’s not just RSA that’s affected; our other main asymmetric key crypto system, Elliptic Curve Cryptography, is similarly severely broken by Shor’s algorithm.

Symmetric cryptosystems such as AES are at some degree of risk, with current quantum algorithms such as Grover’s algorithm able to cut the time to crack them quadratically, however this doesn’t have material impact on practical security as any loss can be countered by simply increasing the key length. For example, AES-128 is designed to provide 128 bits of security; or in other words, an attacker must perform 2^128 operations to brute-force the encryption. This drops to 2^64 with the application of Grovers algorithm. But we can return to 128 bits of security by adopting AES-256 instead.

![image](https://github.com/rot169/pqc/assets/59445582/2375d1ac-4bc1-4c05-b42c-64cd364212d8)

So it’s really just our asymmetric crypto systems – RSA and ECC – that we need to worry about. But that’s still a really big deal. Afterall, asymmetric crypto plays a critical role in not only protecting the symmetric keys we use for most encryption operations, but also in verifying the authenticity of websites and user authentication too.

But do we REALLY need to worry? Sure there’s a lot of hype around quantum computing, but as I record this in mid 2023, no known quantum computer is sufficiently capable of running Shor’s algorithm on the size of numbers required to break any practical cryptographic implementation. 

## Quantum Cryptography

We’ll explore that particular topic further in the third video in this series, but for now but let’s take a quick look at what our options are for replacing our asymmetric crypto systems with something that’s quantum-resistant. Do we too need to turn to the power of quantum computing? Certainly some mechanisms exist to leverage quantum physics to build crypto systems, and there’s a lot of hype from vendors in this space. Solutions include quantum random number generation, and quantum key exchange. But just because something has the word “quantum” slapped on it, it’s not necessarily going to help!

## Quantum Random Number Generation

Quantum Random Number Generation uses those weird properties of quantum physics to generate random numbers. Random numbers are essential in cryptographic systems, and there’s been numerous security vulnerabilities due to cryptosystems that aren’t sufficiently random. Creating true randomness is a tough problem for traditional computers, which are designed to be predictable and repeatable. Some methods of creating randomness – such as the Mersenne Twister function – may appear random at first glance, but actually use a predictable algorithm which allows values to be calculated given enough information. Pseudo-random systems such as this are fine for low-risk applications and games, but are inappropriate for security-significant cases such as cryptosystems. But we do have other ways of creating cryptographically secure randomness using non-quantum properties, such as using the interval between certain hardware events which are subject to considerable jitter. So this begs the question: what makes **quantum** random number generation better than our existing secure random number generation. It’s a good question, and one which doesn’t seem to have a compelling answer. Sure, QRND may produce some perfectly random numbers at a faster rate than our current methods – but our current tech is absolutely fine for now, and will be for the foreseeable future. A key point to note here is that there’s no known or expected vulnerability in our existing secure random number generators posed by the introduction of quantum computing. Don’t just take my word for it – the UK’s National Cyber Security Centre agrees, stating that they believe that “_classical RNGs will continue to meet our needs for government and military applications for the foreseeable future_”.

## Quantum Key Exchange

Ok, so if there’s not a big case for QRND, what about Quantum Key Exchange? To recap on some crypto basics - we prefer to use symmetric algorithms for the majority of encryption purposes as they computationally less expensive so consume less CPU cycles and are far quicker. But, we need a method for parties to securely agree what symmetric key to use without exposing the key to any potential eavesdroppers. That’s the purpose of Key Exchange, and is one of the main use cases for our current public key cryptosystems such as RSA and elliptic curve crypto. As these are set to be broken by quantum computing, Quantum Key Exchange delivers an equivalent method of symmetric key agreement which uses properties of quantum physics to avoid any eavesdroppers, rather than rely on complex mathematical problems. 

The big downside is that specialist hardware devices are required to send and receive the necessary entangled particles to achieve this. Whilst that might not be a big issue for a single point-to-point link, it quickly becomes impractical to equip every single device with such hardware. And point-to-point links aren’t particularly useful in a world where we look to achieve end-to-end security.

So despite sounding cool, neither Quantum Random Number Generation nor Quantum Key Distribution are a suitable replacement for our current public key crypto.

## Quantum-Resistant Cryptography

But we don’t need to use quantum-powered crypto to safeguard ourselves from the threat of quantum computing. Remember, a cryptosystem is only at risk if it’s based on a mathematical problem that a quantum computer has an efficient algorithm for solving. What if we could find a cryptosystem that could run on our existing classical computers, and is based on a mathematical problem that **can't** be easily solved by a quantum computer?

![image](https://github.com/rot169/pqc/assets/59445582/0bac7347-5fa4-4d44-8a42-85b905e57f9f)

Cryptographers have been aware of the quantum threat to our current cryptosystems for many years and have been working on many such alternatives. NIST, the US National Institute for Standards & Technology have been running a selection competition for quantum-resistant algorithms since 2016, and in July 2022 announced the first four algorithms that have proven themselves to be sufficiently robust, practical and performant, and therefore will be enshrined as standards.

* The **CRYSTALS-Kyber** algorithm has been selected to provide public-key encryption and key-exchange.

* The associated **CRYSTALS-Dilithium** algorithm has been selected for providing digital signatures.

* One of the drawbacks of Kyber and Dilithium are the significantly larger key sizes as compared to our current breed of algorithms, so the **Falcon** algorithm was also selected for digital signatures due to its shorter key size, making it a more viable option for embedded systems.

* All three of these algorithms derive their cryptographic strength from the difficulty of solving lattice-based problems. Despite a lot of research into the topic, there’s no known way to programme a quantum computer to solve these problems significantly quicker than a traditional computer. However there’s a chance that some very smart people in the future might find a way, so NIST elected to standardise a fourth quantum-resistant signature algorithm based on an entirely different mathematical foundation. The **SPHINCS+** algorithm is built upon hash-based calculations.

That’s not the end of the road for the NIST competition though; several other candidates are still in the running for standardisation in the future, and cryptoanalysis of the selected algorithms will continue for as long as they’re in use. And that’s a really good thing – because shortly after it was passed-through to the final round, a critical flaw was found in the SIKE algorithm which made it easily breakable by a single consumer-grade laptop, let alone a quantum computer! And research has also identified some side-channel attack vectors in Kyber, however these are currently not perceived to be significant.

## Wrap-up

I’ve intentionally brushed over a lot of the complexity around these new quantum-resistant cryptosystems in this introduction. Afterall, as a security practitioner it’s not always necessary to understand every little detail, just like you don’t need to know the precise inner workings of an engine in order to drive a car. But some intuition can be insightful, so let me know in the comments if you’re interested in the maths underpinning our PQC algorithms and maybe I’ll create a deep dive in the future. 

Coming up next though, it’s time to get hands-on! In the second video in this series we’ll walk through the steps to instantiate a web service and web browser with these quantum-resistant algorithms built-in so you can experience them for yourself right now!

And later on in the series we’ll take a more strategic view around post-quantum cryptographic migrations, and explore what steps you should be thinking about actioning now to start that journey.
