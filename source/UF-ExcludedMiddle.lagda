Martin Escardo.

Excluded middle related things.

In the Curry-Howard interpretation, excluded middle say that every
type has an inhabitant or os empty. In univalent foundations, where
one works with propositions as subsingletons, excluded middle is the
principle that every subsingleton type is inhabited or empty.

\begin{code}

{-# OPTIONS --without-K --exact-split #-}

module UF-ExcludedMiddle where

open import SpartanMLTT
open import UF-Base
open import UF-Subsingletons-FunExt
open import UF-Equiv
open import UF-Embedding
open import UF-PropTrunc

\end{code}

Excluded middle (EM) is not provable or disprovable. However, we do
have that there is no truth value other than false (⊥) or true (⊤),
which we refer to as the density of the decidable truth values.

\begin{code}

EM : ∀ 𝓤 → 𝓤 ⁺ ̇
EM 𝓤 = (P : 𝓤 ̇) → is-prop P → P + ¬ P

WEM : ∀ 𝓤 → 𝓤 ⁺ ̇
WEM 𝓤 = (P : 𝓤 ̇) → is-prop P → ¬ P + ¬¬ P

DNE : ∀ 𝓤 → 𝓤 ⁺ ̇
DNE 𝓤 = (P : 𝓤 ̇) → is-prop P → ¬¬ P → P

EM-gives-DNE : EM 𝓤 → DNE 𝓤
EM-gives-DNE em P isp φ = cases (λ p → p) (λ u → 𝟘-elim (φ u)) (em P isp)

DNE-gives-EM : funext 𝓤 𝓤₀ → DNE 𝓤 → EM 𝓤
DNE-gives-EM fe dne P isp = dne (P + ¬ P)
                             (decidable-types-are-props fe isp)
                             (λ u → u (inr (λ p → u (inl p))))

fem-proptrunc : funext 𝓤 𝓤₀ → EM 𝓤 → propositional-truncations-exist 𝓤 𝓤
fem-proptrunc fe em X = ¬¬ X ,
                        (Π-is-prop fe (λ _ → 𝟘-is-prop) ,
                         (λ x u → u x) ,
                         λ P isp u φ → EM-gives-DNE em P isp (¬¬-functor u φ))

module _ (pt : PropTrunc) where

 open PropositionalTruncation pt

 double-negation-is-truncation-gives-DNE :((X : 𝓤 ̇) → ¬¬ X → ∥ X ∥) → DNE 𝓤
 double-negation-is-truncation-gives-DNE {𝓤} f P isp u = ptrec isp id (f P u)

\end{code}
