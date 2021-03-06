1. In the one example included (Section 5), what is the free theorem being used?

We will try to include the full statement of the free theorem in the Appendix. Note that the full statement depends on translations of other objects mentioned in the object being translated. It also depends
on some combinators that our translation uses.

2. What's the point of R in IffProps?

IffProps only depends on the type of R, not on R itself. In our notation, Coq can infer the actual two arguments of iff by the type of R. But, we can indeed remove the R argument of IffProps.

3. Requiring relationships that are both total and one-to-one (i.e. isomorphisms) is a very strong requirement. For example, one-to-one-ness doesn't seem to be satisfied in the Bessel-Descartes fable, right?

Right. This was also the case in the example in Sec. 5: the relation we chose was alpha equality, which is not one to one.
As explained in https://github.com/aa755/paramcoq-iff/blob/master/examples/necessity.v, the two assumptions are unavoidable in general. 
However, using the discussion in Sec. 3, it is often possible to express propositions in ways that ensure that one or both of the assumptions are  unnecessary. 
For example, in Sec. 5, the one-to-one assumption was not needed. If we had instead defined obsEq using indexed-induction, our unused variable analysis would have failed to remove the one to one assumption: recall from Sec.3 that our translation needs the one to one assumption for indices of inductive types.

Practically speaking, if Professor Bessel and Descartes taught their classes in Coq, they must avoid using indexed inductive propositions whose index type is the abstract type of complex numbers. This implies that they cannot
use Coq.Init.Logic.eq (=) to equate complex numbers. Coq.Init.Logic.eq is an indexed inductive proposition. However, they CAN Coq.Init.Logic.eq to equate concrete types such as booleans : we do so in the example in Sec. 5.
They would probably include an abstract equality relation in the interface of complex numbers, and only use that to talk about equality of complex numbers.
This is very doable: the algebraic hierarchy defined in MathClasses almost totally shuns Coq.Init.Logic.eq. Algebraic structures such as rings have their own equality in the interface:
https://github.com/math-classes/math-classes/blob/v8.5/interfaces/abstract_algebra.v#L69

4. Whether you need higher universes depends on how you are proving something, not what you are proving?

It does depend on what you are proving. For example, by Godel's incompleteness theorem, ANY proof of consistency of Coq's Set universe must live in a higher universe. But you are right that for the same statement, there can be different proofs with different universe requirements.


5. What if you do the regular translation after you desugar the indexed data type to a parametrized data type with embedded equality proofs for the indices?

Even in that approach, one needs to translate the equality type, which is an indexed-inductive type. Also, if there are several dependent indices, some of the problems in Sec 2.3 would appear anyway.
In practice, a translation that proceeds via the encoding may be harder to understand because users may first need to understand how their indexed inductive types get encoded.

6. What does the IsoRel translation produce: Coq or Gallina? 

Fully elaborated Gallina terms

7. Does the translation use axioms?

Our AnyRel translation does NOT use any axiom. 
It would be wrong to use axioms at some places: to preserve typehood judgments, the translation must preserve reductions (beta, iota, etc.).
Our IsoRel translation does use axioms, but not at places that block the preservation of reductions: axioms are ONLY used in the proofs of the Total and OneToOne properties.
For example, using a reflexivity proof, the following file shows that the iota reduction (pattern matching) for the recursion principle for W type is preserved by the IsoRel translation:
https://github.com/aa755/paramcoq-iff/blob/master/test-suite/iso/IWTS.v
The preservation of beta reduction is obvious: lambdas get translated to triple lambdas and correspondingly, application gets translated to triple application (see Sec. 4.1).


8.  Since both styles are supposed to be isomorphic, and deductive-style allows proof by computation, is it feasible to make a Coq tactic that takes care of proofs for the inductive- style?

Yes. As explained in Sec. 2.2, we implemented both the inductive-style translation and the deductive-style translation.
It may be not so hard to implement the generation of functions to go back and forth between the two styles.

9. Why is it necessary to generate proofs of the form Fix F = F (Fix F) while translating fixpoints? How does this relate to the translation?

Marc Lasson explained the main idea here:
https://github.com/mlasson/paramcoq/issues/4

After the translating the body of a Coq fixpoint, we "rewrite" its type with the proofs of the propositional equalities  F (Fix F) = Fix F  and F' (Fix F') = Fix F'. 
https://github.com/aa755/paramcoq-iff/blob/master/paramDirect.v#L901


10.  The fact that the relations in Prop might be undecidable isn't what makes the translation difficult, right?

If all relations in Prop were decidable, the IsoRel translation would be unnecessary.
Decidable relations in Prop can be rewritten as relations in bool, and thus the AnyRel translation would then suffice to obtain the free proofs of uniformity.

