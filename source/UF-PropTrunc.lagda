Martin Escardo

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

module UF-PropTrunc where

open import SpartanMLTT
open import UF-Base public
open import UF-Subsingletons public
open import UF-FunExt public
open import UF-Subsingletons-FunExt public

\end{code}

We use the existence of propositional truncations as an
assumption. The following type collects the data that constitutes this
assumption.

\begin{code}

record propositional-truncations-exist : Uω where
 field
  ∥_∥ : {𝓤 : Universe} → 𝓤 ̇ → 𝓤 ̇
  propositional-truncation-is-a-prop : {𝓤 : Universe} {X : 𝓤 ̇} → is-prop ∥ X ∥
  ∣_∣ : {𝓤 : Universe} {X : 𝓤 ̇} → X → ∥ X ∥
  ptrec : {𝓤 𝓥 : Universe} {X : 𝓤 ̇} {Y : 𝓥 ̇} → is-prop Y → (X → Y) → ∥ X ∥ → Y
 infix 0 ∥_∥
 infix 0 ∣_∣

module PropositionalTruncation (pt : propositional-truncations-exist) where

 open propositional-truncations-exist pt public

 is-singleton'-is-prop : {X : 𝓤 ̇} → funext 𝓤 𝓤 → is-prop(is-prop X × ∥ X ∥)
 is-singleton'-is-prop fe = Σ-is-prop (being-a-prop-is-a-prop fe) (λ _ → propositional-truncation-is-a-prop)

 c-es₁ : {X : 𝓤 ̇} → is-singleton X ⇔ is-prop X × ∥ X ∥
 c-es₁ {𝓤} {X} = f , g
  where
   f : is-singleton X → is-prop X × ∥ X ∥
   f (x , φ) = singletons-are-props (x , φ) , ∣ x ∣

   g : is-prop X × ∥ X ∥ → is-singleton X
   g (i , s) = ptrec i id s , i (ptrec i id s)

 ptfunct : {X : 𝓤 ̇} {Y : 𝓥 ̇} → (X → Y) → ∥ X ∥ → ∥ Y ∥
 ptfunct f = ptrec propositional-truncation-is-a-prop (λ x → ∣ f x ∣)

 ∃ : {X : 𝓤 ̇} → (Y : X → 𝓥 ̇) → 𝓤 ⊔ 𝓥 ̇
 ∃ Y = ∥ Σ Y ∥

 _∨_  : 𝓤 ̇ → 𝓥 ̇ → 𝓤 ⊔ 𝓥 ̇
 P ∨ Q = ∥ P + Q ∥

 left-fails-then-right-holds : {P : 𝓤 ̇} {Q : 𝓥 ̇} → is-prop Q → P ∨ Q → ¬ P → Q
 left-fails-then-right-holds i d u = ptrec i (λ d → Left-fails-then-right-holds d u) d

 right-fails-then-left-holds : {P : 𝓤 ̇} {Q : 𝓥 ̇} → is-prop P → P ∨ Q → ¬ Q → P
 right-fails-then-left-holds i d u = ptrec i (λ d → Right-fails-then-left-holds d u) d

 pt-gdn : {X : 𝓤 ̇} → ∥ X ∥ → ∀ {𝓥} (P : 𝓥 ̇) → is-prop P → (X → P) → P
 pt-gdn {𝓤} {X} s {𝓥} P isp u = ptrec isp u s

 gdn-pt : {X : 𝓤 ̇} → (∀ {𝓥} (P : 𝓥 ̇) → is-prop P → (X → P) → P) → ∥ X ∥
 gdn-pt {𝓤} {X} φ = φ ∥ X ∥ propositional-truncation-is-a-prop ∣_∣

 pt-dn : {X : 𝓤 ̇} → ∥ X ∥ → ¬¬ X
 pt-dn s = pt-gdn s 𝟘 𝟘-is-prop

 binary-choice : {X : 𝓤 ̇} {Y : 𝓥 ̇} → ∥ X ∥ → ∥ Y ∥ → ∥ X × Y ∥
 binary-choice s t = ptrec propositional-truncation-is-a-prop (λ x → ptrec propositional-truncation-is-a-prop (λ y → ∣ x , y ∣) t) s

 infixr 0 _∨_

\end{code}
