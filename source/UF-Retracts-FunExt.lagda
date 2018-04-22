\begin{code}

{-# OPTIONS --without-K --exact-split #-}

module UF-Retracts-FunExt where

open import UF-Base
open import UF-Retracts
open import UF-FunExt

rexp : ∀ {U V W T} {X : U ̇} {Y : V ̇} {X' : W ̇} {Y' : T ̇} → FunExt U T
    → retract X of X' → retract Y' of Y → retract (X → Y') of (X' → Y)
rexp {U} {V} {W} {T} {X} {Y} {X'} {Y'} fe (rx , (sx , rsx)) (ry , (sy , rsy)) = (r , (s , rs))
 where
  r : (X' → Y) → X → Y'
  r f x = ry (f (sx x))
  s : (X → Y') → X' → Y
  s f' x' = sy (f' (rx x'))
  rs' : (f' : X → Y') (x : X) → ry (sy (f' (rx (sx x)))) ≡ f' x
  rs' f' x = rsy (f' (rx (sx x))) ∙ ap f' (rsx x)
  rs : (f' : X → Y') → r (s f') ≡ f'
  rs f' = funext fe (rs' f')

rpe : ∀ {U V W} {X : U ̇} {Y : V ̇} {Y' : W ̇} → FunExt U W
    → retract Y' of Y → retract (X → Y') of (X → Y)
rpe fe = rexp fe identity-retraction

crpe : ∀ {U V W} {X : U ̇} {Y : V ̇} {X' : W ̇} → FunExt U V
    → retract X of X' → retract (X → Y) of (X' → Y)
crpe fe rx = rexp fe rx identity-retraction

pdrc : ∀ {U V} {X : U ̇} {Y : V ̇} → X → retract Y of (X → Y)
pdrc x = ((λ f → f x) , ((λ y x → y) , λ y → refl))

retracts-of-closed-under-exponentials : ∀ {U V W} {X : U ̇} {Y : V ̇} {B : W ̇} → FunExt W W
                                      → X → retract B of X → retract B of Y → retract B of (X → Y)
retracts-of-closed-under-exponentials {U} {V} {W} {X} {Y} {B} fe x rbx rby = rbxy
 where
  rbbxy : retract (B → B) of (X → Y)
  rbbxy = rexp fe rbx rby
  rbxy : retract B of (X → Y)
  rbxy = retracts-compose rbbxy (pdrc (pr₁ rbx x))

\end{code}
