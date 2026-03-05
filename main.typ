#import "@preview/slydst:0.1.5": *
#import "@preview/algorithmic:1.0.7"
#import "algorithmic.typ"
#import algorithmic: algorithm-figure, style-algorithm

#show: style-algorithm
#show: slides.with(
  title: "Prio: Private, Robust, and Scalable Computation of Aggregate Statistics",
  subtitle: none,
  date: "2026/3/6",
  authors: "GOTO Naoto",
  ratio: 16 / 9,
  subslide-numbering: "(i)",
)

#set text(size: 12pt)
#let blink(x, y) = text(blue, link(x, y))
#let otheorem(x) = theorem(x, fill-header: orange.lighten(65%))

#show raw: set block(fill: silver.lighten(65%), width: 100%, inset: 1em)

== Outline

#outline()

= Preleminaries

== Secure Computation
#v(0.3em)

Secure compuation is a technique to run a computation while keeping th input data private.

Mainly, three techniques are known for secure computation:
- homomorphic encryption
- trusted execution environment (TEE)
- multi-party computation
#figure(
  table(
    columns: 3,
    stroke: 1pt,
    align: center,

    [], [Transmission / Storage], [Computation],

    [Encryption (RSA, AES)], [⭕️], [❌],
    [Secure Computation], [⭕️], [⭕️],
  ),
  caption: [Operations Possible While Data Remains Encrypted],
)

#pagebreak()
#v(0.3em)

=== Homomorphic Encryption
#set text(size: 12pt)

#let Enc = math.op("Enc")

#definition(title: "Homomorphic Encryption")[
  An encryption scheme $cal(E)$ is said to have the homomorphic property if,
  for an operation $circle.small$ on the plaintext space $cal(M)$ and an
  operation $star$ on the ciphertext space $cal(C)$, the following property holds:

  #align(center)[
    #box(inset: 1em, stroke: 1pt)[
      $forall m_1, m_2 in cal(M): quad
      Enc(m_1) star Enc(m_2) = Enc (m_1 circle.small m_2)$
    ]
  ]

  That is, decrypting the result of an operation on ciphertexts yields the same
  result as applying the corresponding operation to the plaintexts.
]
RSA is an example of a homomorphic encryption scheme where a computation is multiplication.

$
  Enc(m) = m^e mod n \
  Enc(m_1) Enc(m_2) = Enc(m_1 m_2)
$

#pagebreak()
#v(0.3em)

=== Trusted Execution Environment (TEE)
Trusted Execution Environment (TEE) is a *hardware support* that provides an isolated environment for executing code and processing data.
TEE is employed in various applications, such as managing secure keys, mobile payments, and biometric authentication.

ex) Intel SGX, ARM TrustZone

SORRY for a little content here.....

#pagebreak()
#v(0.3em)
=== Multi-Party Computation
Secure Multi-Party Computation (MPC) allows multiple parties to *jointly compute* a function over their inputs
while keeping those inputs private.

Let there be $n$ parties $P_1, dots, P_n$, where party $P_i$
holds a private input $x_i$.
Given a public function $f$, the goal of MPC is to compute

$y = f(x_1, x_2, dots, x_n)$

such that, apart from what can be inferred from the output $y$ (and any
allowed auxiliary information), no party learns anything about the other
parties' inputs.

Spliting inputs into shares and distributing them among parties is a common approach in MPC.

#let Comp = math.op("Compute")

#pagebreak()
Data $a$ is splited into three shares, and every administrator computes its share.
#figure(
  image("figs/mpc.png", height: 67%),
  caption: [Secure Multi-Party Computation (MPC)#footnote[https://www.nec.com/en/global/techrep/journal/g16/n02/images/160211_01.png]],
)

== Multi-Party Computation
#v(0.3em)
The flow of MPC is as follows:

1. Each party splits its private input into shares and distributes them to other parties.
2. Each party performs computations on the shares it has received. These computations may include additions, multiplications, or more complex operations depending on the protocol.
3. After the computations, the parties exchange the results of their computations.
4. Finally, the parties combine the results to obtain the final output.

Here are two main techniques for splitting data into shares:

- Shamir's Secret Sharing
- Additive Secret Sharing

== Shamir's Secret Sharing
#v(0.3em)
Shamir's Secret Sharing is a $(t, n)$ threshold scheme that splits a secret into $n$ shares such that any $t$ shares can reconstruct the secret, while fewer than $t$ shares reveal no information about it. The scheme is widely used in cryptography to distribute trust and tolerate failures or compromises.

The idea is to encode the secret as the constant term of a random polynomial over a finite field. Choose a prime $p$ (or, more generally, a finite field $FF$) and represent the secret as $s in FF$. Then sample a random polynomial

$ f(x) = s + a_1 x + a_2 x^2 + dots.c + a_(t-1) x^(t-1) $

where the coefficients $a_1, dots.c, a_(t-1)$ are chosen uniformly at random from $FF$. For $n$ distinct nonzero points $x_1, dots.c, x_n$, the $i$-th share is the pair $(x_i, f(x_i))$.

To reconstruct the secret, any set of at least $t$ parties combines their shares and uses Lagrange interpolation to recover $f(0)$, which equals the secret $s$. 

Security follows from the fact that *with fewer than $t$ points, the polynomial is underdetermined*: infinitely many degree-$(t-1)$ polynomials match those points.
=== Example of Shamir's Secret Sharing
#set text(size: 11pt)
We build a $(t, n) = (3, 5)$ Shamir secret sharing scheme over the finite field $FF_(17)$. Let the secret be $s = 5$ and choose a random degree-2 polynomial

$ f(x) = s + a_1 x + a_2 x^2 quad (mod 17) $

with $a_1 = 2$ and $a_2 = 7$.
So, 
$
f(x) = 5 + 2x + 7x^2 quad (mod 17)
$

==== Step 1: Share generation

We pick distinct nonzero $x$ values and compute $y_i = f(x_i)$.

#table(
  columns: 2,
  [$(x_i, f(x_i))$], [value in $FF_(17)$],
  [$(1, f(1))$], [$f(1)=5+2 dot 1+7 dot 1^2=14$],
  [$(2, f(2))$], [$f(2)=5+2 dot 2+7 dot 2^2=37 equiv 3$],
  [$(3, f(3))$], [$f(3)=5+2 dot 3+7 dot 3^2=74 equiv 6$],
  [$(4, f(4))$], [$f(4)=5+2 dot 4+7 dot 4^2=125 equiv 6$],
  [$(5, f(5))$], [$f(5)=5+2 dot 5+7 dot 5^2=190 equiv 3$],
)

==== Step 2: Reconstruction from 3 shares

Take any 3 shares, e.g. $(1,14), (2,3), (3,6)$.

Using Lagrange interpolation over the field, we recover $f(0)$:

$ f(0) = sum_(i=1)^(3) y_i ell_i(0) quad (mod 17), quad ell_i(x)=product_(j != i) frac(x-x_j, x_i-x_j). $

Compute the basis values at $x=0$:

- For $x_1=1$:
  $ ell_1(0) = frac(0-2, 1-2) dot frac(0-3, 1-3) = frac(-2, -1) dot frac(-3, -2) = frac(6, 2). $
  In $FF_(17)$, $2^(-1) equiv 9$ (since $2 dot 9=18 equiv 1$), so
  $ ell_1(0) equiv 6 dot 9 = 54 equiv 3. $

- For $x_2=2$:
  $ ell_2(0)=frac(0-1, 2-1) dot frac(0-3, 2-3) = frac(-1, 1) dot frac(-3, -1) = frac(3, -1). $
  Since $(-1) equiv 16$ and $16^(-1) equiv 16$ in $FF_(17)$,
  $ ell_2(0) equiv 3 dot 16 = 48 equiv 14. $

- For $x_3=3$:
  $ ell_3(0)=frac(0-1, 3-1) dot frac(0-2, 3-2) = frac(-1, 2) dot frac(-2, 1) = frac(2, 2). $
  Thus
  $ ell_3(0) equiv 1. $

So,

$ f(0) equiv 14 dot 3 + 3 dot 14 + 6 dot 1= 42 + 42 + 6 = 90 equiv 5 quad (mod 17). $

Therefore the reconstructed secret is $s = f(0) = 5$.

#pagebreak()
=== ADD computation
Assume two secrets $s_1, s_2 in FF_p$ are shared by
polynomials $f_1(x)$ and $f_2(x)$ of degree at most $(t-1)$.

Each participant $i$ holds the shares

$y_{1,i} = f_1(i), quad y_{2,i} = f_2(i)$.

Define the polynomial

$f_+(x) = f_1(x) + f_2(x)$.

Since polynomial addition is coefficient-wise,
$f_+(x)$ also has degree at most $(t-1)$ and

$f_+(0) = f_1(0) + f_2(0) = s_1 + s_2$.

Moreover, for each participant $i$,

$y_{+,i} = y_{1,i} + y_{2,i}
         = f_1(i) + f_2(i)
         = f_+(i)$.

Thus, locally adding their shares is sufficient for the participants to obtain shares of the sum $s_1 + s_2$ without revealing their individual secrets.

=== MULTIPLICATION computation
Define the polynomial

$f_*(x) = f_1(x) f_2(x)$.

Since the product of two polynomials of degree at most $(t-1)$
has degree at most $2(t-1)$, the polynomial $f_*(x)$ satisfies

$f_*(0) = f_1(0) f_2(0) = s_1 s_2$.

Moreover, for each participant $i$,

$y_{*,i} = y_{1,i} y_{2,i}
         = f_1(i) f_2(i)
         = (f_1 f_2)(i)
         = f_*(i)$.

Thus, by locally multiplying their shares,
participants obtain shares of the secret $s_1 s_2$.
The resulting polynomial has degree at most $2(t-1)$.

To restore the threshold $t$, a degree reduction
protocol is applied, which involves sharing the shares of $f_*(i)$ using a new random degree-$(t-1)$ polynomial and reconstructing $f_*(0)$ from the new shares. 

== Additive Secret Sharing

Additive Secret Sharing is a simple secret sharing scheme in which a secret is split into multiple shares such that the *sum of the shares equals the secret*. It is commonly used in secure multi-party computation (MPC) due to its simplicity and efficient support for linear operations.

The scheme typically works over a finite field $FF$ (for example $Z_p$ for a prime $p$). Let the secret be represented as $s in FF$.

The goal is to generate $n$ shares $x_1, x_2, dots.c, x_n in FF $ such that

$ x_1 + x_2 + dots.c + x_n = s $
To generate the shares, sample $n-1$ values uniformly at random from $FF$:
$ x_1, x_2, dots.c, x_(n-1) ← FF $
Then compute the final share as
$ x_n = s - (x_1 + x_2 + dots.c + x_(n-1)) $

Each party $P_i$ receives one share $x_i$.

#pagebreak()

=== MULTIPLICATION computation (Beaver Triples)
All computations below are performed over the finite field $FF$.

A Beaver triple consists of three random values $(a, b, c) $
such that
$c = a b $.

These values are secret-shared among the participants:

$ a = a_1 + a_2 + dots.c + a_n $

$ b = b_1 + b_2 + dots.c + b_n $

$ c = c_1 + c_2 + dots.c + c_n $

Each participant $i$ holds the shares $(a_i, b_i, c_i)$.
The triple is generated during a preprocessing phase and is independent
of the secrets that will later be multiplied.
==== Goal
Suppose two secrets $x = x_1 + x_2 + dots.c + x_n $ and
$y = y_1 + y_2 + dots.c + y_n $
are shared among the participants.
The goal is to obtain shares of the product

$ x y $

without revealing $x$ or $y$.

==== Step 1: Mask the Secrets

Each participant locally computes

$ d_i = x_i - a_i $

$ e_i = y_i - b_i $

Then the parties reconstruct the public values

$ d = sum_i d_i = x - a $

$ e = sum_i e_i = y - b $.

Since $a$ and $b$ are random and unknown to the parties,
revealing $d$ and $e$ does not leak information about $x$ or $y$.

==== Step 2: Compute Shares of the Product

Using the identity

$ x y = (a + d)(b + e) $

we expand

$ x y = a b + d b + e a + d e $.

Because $c = a b$, we can rewrite this as

$ x y = c + d b + e a + d e $

Each participant then computes a share of the product as

$ z_i = c_i + d b_i + e a_i $

and one designated participant (or all parties with a correction term)
adds the public value $d e$ so that

$ z_1 + z_2 + dots.c + z_n = x y $

Thus the shares

$ z_1, z_2, dots.c, z_n $

represent the secret

$ x y $ without revealing any information about $x$ or $y$ to the parties.

== Where to em


= Overview: Prio
== Overview of the paper

Title: Prio: Private, Robust, and Scalable Computation of Aggregate Statistics

Authors: Henry Corrigan-Gibbs and Dan Boneh

Publication: USENIX Symposium on Networked Systems Design and Implementation 2017