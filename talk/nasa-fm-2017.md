#

\begin{center}
\Large
Modular Model-Checking of a Byzantine Fault-Tolerant Protocol
\footnote{Supported by NASA Contract NNL14AA08}

\vspace{2cm}
\normalsize
Benjamin F Jones\footnote{Galois, Inc. -- \url{http://galois.com}} and
Lee Pike\footnotemark[2]
\end{center}


# Challenge

Model checking distributed, fault-tolerant systems is challenging:

- large state spaces
- non-determinism
- complexity inherent in modeling interacting nodes subject to various fault
  modes


# Coping with complexity

Model-checking these systems has been accomplished by resorting to ad-hoc
abstractions:

- local node behavior is abstracted (e.g. replaced by pre/post conditions)
- message passing is simplified using shared state
- systems are modeled at small, fixed scales

Ad-hoc abstraction tends to cause a model to *\textcolor{blue}{diverge from
an implementation}*,
reducing its applicability.


# Modularity

* Model-checking these systems is further complicated when system behavior and
fault behavior are mixed in the model.

* _Compositional reasoning_: reason about node behavior and fault
model separately, then compose the proofs


# What We Want in a Model

The premise for this work is that we want, _ideally_, to produce formal models
of distributed systems that:

1. have implementation-level detail,
2. are tractable to the model checker,
3. and are modular to the extent possible.


# What We've Done

* **Framework**: We've attempted to come up with a fairly general framework for modeling
distributed, fault-tolerant systems in a way that gets us closer to the ideal
of the 3 last points.

* **Case Study**: We've taken this framework and used it to model variations on the
  _Oral Messages_ algorithm that vary in their timing model, node
  behavior, and fault model.

* First model-checked verification of $\mathrm{OMH}(1)$ that:
    - does not elide implementation level detail
    - is parameterized over the number of nodes (verified up to 12 nodes)
    - has a modular, inductive proof


# Oral Messages with 1 Round

\begin{center}
\includegraphics[scale=0.5]{om1_diagram.pdf}
\end{center}


# Hybrid Fault Model

Thambidurai and Park introduced their "Hybrid Fault Model"
\footnote{P. Thambidurai and Y.K. Park. \emph{Interactive consistency with multiple failure modes}. Symposium on Reliable Distributed Systems, 1988.}
which captures 4 different fault modes and a system for weighting their impact.

* Non-faulty
* Manifestly faulty
* Symmetrically faulty
* Byzantine faulty

$\mathrm{OM(1)}$ was shown to be tolerant of a certain weighted sum of these fault types.
In the classical case where only byzantine faults are considered and their are
3 lieutenants, the system tolerates at most 1 fault.


# Hybrid Oral Messages Algorithm

* In the course of formalizing this result on fault-tolerance, it was discovered
\footnote{P. Lincoln and J. Rushby. \emph{A formally verified algorithm for interactive consistency under a hybrid fault model}. In Fault Tolerant Computing Symposium 23, 1993.}
that the proof was wrong. However, the $\mathrm{OM(1)}$ algorithm can be adapted
to one that satisfies the conclusion of Thambidurai and Park.

* This algorithm, due to Lincoln and Rushby, is called $\mathrm{OMH(1)}$.


# Three Systematic Abstractions

In this framework for modeling systems, we use three principal abstractions:

1. Calendar automata
    - modeling message passing, including details like
      real time, message delay, buffering, ...
2. Symbolic fault injection
    - injecting faults into the model in a way that is decoupled from local
      node behavior
3. Abstract transition systems
    - strengthening invariants needed to verify properties of the system
      without having to abstract actual system behavior


# Symbolic Fault Injection

* typical approach to modeling faults: add a new state variable to for each
node, indicating fault state. The node's logic then acts on this value.

\begin{center}
\includegraphics[scale=1.0]{fstate.pdf}
\end{center}


# Fault Injection

Fault injection divorces fault behavior from node behavior by injecting faults at the
channel level.

* faulty values are represented as uninterpreted constants
* faulty values are constrained depending on the fault type
* separation of concerns allows us to reason about the fault model in
  isolation from local node behavior


# Verification: Lemma Diagram

Our verification of the case study proceeds by $k$-induction, using SAL
\footnote{SAL. Computer Science Lab, SRI International.
\url{http://sal.csl.sri.com}}.
We strengthen the inductive hypothesis using hand-crafted lemmas which are
organized as follows:

\begin{center}
\includegraphics[scale=0.75]{proof-structure.pdf}
\end{center}


#

\begin{center}
\includegraphics[scale=0.3]{proof-structure-agreement.jpeg}
\end{center}


# Modularity: Variant Models

To assess how modular our modeling framework is, we experimented on our case
study, adding or changing features of the model and measuring how much effort
was required to make the changes and verify the result.

1. Omissive assymetric faults
2. Time triggered message passing
3. Mid-value selection voting


# Omissive Assymetric Faults

Consider changing the fault model:

* Removing all faults from the model is easy: we simply set the maximum
weighted sum in the maximum fault assumption to zero.

* Adding a new fault mode is more work, but is still modular:
  - we add a new uninterpreted function definition for omissive asymmetric
    faults
  - we modify the fault type definition in SAL
  - finally, we define the effect of this new fault type on the calendar

\begin{center}
  \scalebox{0.5}{%
  \begin{tabular}{|p{3cm}|p{2cm}|p{2cm}|p{2cm}|}
  \hline
                                  & Definitions\linebreak (58 total) & Invariants\linebreak (11 total) & Invariant classes\linebreak (5 total) \\
  \hline \hline
Omissive \mbox{Asymmetric} Faults       & \mbox{1 new, 2} \mbox{modified} & 2 modified & faults             \\
  \hline
  \end{tabular}
  }%
\end{center}


# Future Work

As part of NASA Contract NNL14AA08 we are working on a modeling workbench (DSL
and surrounding tools) to support modeling in the framework described here.

\begin{center}
\includegraphics[scale=0.75]{adsl.pdf}
\end{center}
