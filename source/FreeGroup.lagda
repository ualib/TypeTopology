Martin Escardo, January - February 2021.

Ongoing joint work with Marc Bezem, Thierry Coquand, and Peter Dybjer.

For the moment this file is not for public consumption, but it is
publicly visible.

We construct free groups in HoTT/UF in Agda without HIT's other than
propositional truncation, and with no consequence of univalence other
than function extensionality and propositional extensionality.

This is based on Fred Richman's book on constructive algebra. In
particular, this construction shows that the inclusion of generators
is injective (and hence an embedding in the sense of HoTT/UF). It is
noteworthy and surprising that the set of generators is not required
to have decidable equality.

This is part of Martin Escardo's Agda development TypeTopology,
whose philosophy is to be Spartan. At the moment we are a little bit
Athenian, though, with the use of Agda lists rather than Spartan-MLTT
constructed lists, although we intend to fix this in the future. (The
way to do it is already present in the module Fin.lagda.)

\begin{code}

{-# OPTIONS --without-K --safe #-} -- --exact-split

\end{code}

NB. This repository is supposed to use exact-split, but even though
everything has been developed using case-split, the exact-split check
fails (in Agda 2.6.1) in the helper function f of the function
church-rosser. This seems to be a bug, but we are not sure.

\begin{code}

module FreeGroup where

open import SpartanMLTT
open import Groups
open import Two
open import Two-Properties
open import List

open import UF-PropTrunc
open import UF-Univalence
open import UF-Base
open import UF-Subsingletons
open import UF-Subsingletons-FunExt
open import UF-Embeddings
open import UF-Equiv
open import UF-UA-FunExt
open import UF-FunExt

\end{code}

We now construct the group freely generated by a set A. The set-hood
requirement is needed later only, and so we don't include it as an
assumption in the following anonymous module:

\begin{code}

module free-group-construction
        {𝓤 : Universe}
        (A : 𝓤 ̇ )
       where

 X : 𝓤 ̇
 X = 𝟚 × A

 _⁻ : X → X
 (n , a)⁻ = (complement n , a)

 inv-invol : (x : X) → (x ⁻)⁻ ≡ x
 inv-invol (n , a) = ap (_, a) (complement-involutive n)

\end{code}

The idea is that list concatenation _++_ will be the group operation
after suitable quotienting, with the empty list [] as the neutral
element.

We will quotient the following type FA to get the undelying type of
the free group:

\begin{code}

 FA : 𝓤 ̇
 FA = List X

 η : A → FA
 η a = [ (₀ , a) ]

\end{code}

The type 𝟚 has two elements ₀ and ₁, and a prefix ₁ to an element a of
the type A means it is formally inverted. So in the inclusion of
generators η we indicate that the element a is not inverted by
prefixing it with ₀.

We will quotient by the equivalence relation generated by the
following reduction relation:

\begin{code}

 _▷_ : FA → FA → 𝓤 ̇
 s ▷ t = Σ u ꞉ FA , Σ v ꞉ FA , Σ x ꞉ X , (s ≡ u ++ [ x ] ++ [ x ⁻ ] ++ v)
                                       × (t ≡ u ++ v)

 infix 1 _▷_

 ∷-▷ : {s t : FA} (x : X) → s ▷ t → x ∷ s ▷ x ∷ t
 ∷-▷ x (u , v , y , p , q) = (x ∷ u) , v , y , ap (x ∷_) p , ap (x ∷_) q

\end{code}

The following is a lemma for the Church-Rosser property, proved by
induction on u₀ and u₁:

\begin{code}

 church-rosser : (u₀ v₀ u₁ v₁ : FA) (x₀ x₁ : X)

               → u₀ ++  [ x₀ ] ++ [ x₀ ⁻ ] ++ v₀
               ≡ u₁ ++  [ x₁ ] ++ [ x₁ ⁻ ] ++ v₁

               → (u₀ ++ v₀ ≡ u₁ ++ v₁)
               + (Σ t ꞉ FA , (u₀ ++ v₀ ▷ t) × (u₁ ++ v₁ ▷ t))

 church-rosser u₀ v₀ u₁ v₁ x₀ x₁ = f u₀ u₁
  where
   f : (u₀ u₁ : FA)
     → u₀ ++  [ x₀ ] ++ [ x₀ ⁻ ] ++ v₀ ≡ u₁ ++  [ x₁ ] ++ [ x₁ ⁻ ] ++ v₁
     → (u₀ ++ v₀ ≡ u₁ ++ v₁) + (Σ t ꞉ FA , (u₀ ++ v₀ ▷ t) × (u₁ ++ v₁ ▷ t))

   f [] [] p = inl γ
    where
     have : x₀ ∷ x₀ ⁻  ∷ v₀
          ≡ x₁ ∷ x₁ ⁻  ∷ v₁
     have = p

     γ : v₀ ≡ v₁
     γ = equal-tails (equal-tails p)

   f [] (y₁ ∷ []) p = inl γ
    where
     have : x₀ ∷ x₀ ⁻ ∷ v₀
          ≡ y₁ ∷ x₁   ∷ x₁ ⁻ ∷ v₁
     have = p

     q = x₁ ⁻    ≡⟨ ap _⁻ ((equal-heads (equal-tails p))⁻¹) ⟩
         (x₀ ⁻)⁻ ≡⟨ inv-invol x₀ ⟩
         x₀      ≡⟨ equal-heads p ⟩
         y₁      ∎

     γ : v₀ ≡ y₁ ∷ v₁
     γ = transport (λ - → v₀ ≡ - ∷ v₁) q (equal-tails (equal-tails p))

   f [] (y₁ ∷ z₁ ∷ u₁) p = inr γ
    where
     have : x₀ ∷ x₀ ⁻ ∷ v₀
          ≡ y₁ ∷ z₁   ∷ u₁ ++ [ x₁ ] ++ [ x₁ ⁻ ] ++ v₁
     have = p

     d' : u₁ ++ [ x₁ ] ++ [ x₁ ⁻ ] ++ v₁ ▷ u₁ ++ v₁
     d' = u₁ , v₁ , x₁ , refl , refl

     d : v₀ ▷ u₁ ++ v₁
     d = transport (_▷ u₁ ++ v₁) ((equal-tails (equal-tails p))⁻¹) d'

     q = y₁ ⁻ ≡⟨ (ap (_⁻) (equal-heads p)⁻¹) ⟩
         x₀ ⁻ ≡⟨ equal-heads (equal-tails p) ⟩
         z₁   ∎

     e' : y₁ ∷ y₁ ⁻ ∷ u₁ ++ v₁ ▷ u₁ ++ v₁
     e' = [] , (u₁ ++ v₁) , y₁ , refl , refl

     e : y₁ ∷ z₁ ∷ u₁ ++ v₁ ▷ u₁ ++ v₁
     e = transport (λ - → y₁ ∷ - ∷ u₁ ++ v₁ ▷ u₁ ++ v₁) q e'

     γ : Σ t ꞉ FA , (v₀ ▷ t) × (y₁ ∷ z₁ ∷ u₁ ++ v₁ ▷ t)
     γ = (u₁ ++ v₁) , d , e

   f (y₀ ∷ []) [] p = inl γ
    where
     have : y₀ ∷ x₀   ∷ x₀ ⁻ ∷ v₀
          ≡ x₁ ∷ x₁ ⁻ ∷ v₁
     have = p

     γ = y₀ ∷ v₀      ≡⟨ ap (_∷ v₀) (equal-heads p) ⟩
         x₁ ∷ v₀      ≡⟨ ap (_∷ v₀) ((inv-invol x₁)⁻¹) ⟩
         (x₁ ⁻)⁻ ∷ v₀ ≡⟨ ap (λ - → - ⁻ ∷ v₀) ((equal-heads (equal-tails p))⁻¹) ⟩
         x₀ ⁻ ∷ v₀    ≡⟨ equal-tails (equal-tails p) ⟩
         v₁           ∎

   f (y₀ ∷ z₀ ∷ u₀) [] p = inr γ
    where
     have : y₀ ∷ z₀   ∷ u₀ ++ [ x₀ ] ++ [ x₀ ⁻ ] ++ v₀
          ≡ x₁ ∷ x₁ ⁻ ∷ v₁
     have = p

     q = y₀ ⁻ ≡⟨ ap (_⁻) (equal-heads p) ⟩
         x₁ ⁻ ≡⟨ (equal-heads (equal-tails p))⁻¹ ⟩
         z₀   ∎

     d' : y₀ ∷ y₀ ⁻ ∷ u₀ ++ v₀ ▷ u₀ ++ v₀
     d' = [] , (u₀ ++ v₀) , y₀ , refl , refl

     d : y₀ ∷ z₀ ∷ u₀ ++ v₀ ▷ u₀ ++ v₀
     d = transport (λ - → y₀ ∷ - ∷ u₀ ++ v₀ ▷ u₀ ++ v₀) q d'

     e' : u₀ ++ [ x₀ ] ++ [ x₀ ⁻ ] ++ v₀ ▷ u₀ ++ v₀
     e' = u₀ , v₀ , x₀ , refl , refl

     e : v₁ ▷ u₀ ++ v₀
     e = transport (_▷ u₀ ++ v₀) (equal-tails (equal-tails p)) e'

     γ : Σ t ꞉ FA , (y₀ ∷ z₀ ∷ u₀ ++ v₀ ▷ t) × (v₁ ▷ t)
     γ = (u₀ ++ v₀) , d , e

   f (y₀ ∷ u₀) (y₁ ∷ u₁) p = γ
    where
     have : y₀ ∷ u₀ ++ [ x₀ ] ++ [ x₀ ⁻ ] ++ v₀
          ≡ y₁ ∷ u₁ ++ [ x₁ ] ++ [ x₁ ⁻ ] ++ v₁
     have = p

     IH : (u₀ ++ v₀ ≡ u₁ ++ v₁) + (Σ t ꞉ FA , (u₀ ++ v₀ ▷ t) × (u₁ ++ v₁ ▷ t))
     IH = f u₀ u₁ (equal-tails p)

     Γ : X → X → 𝓤 ̇
     Γ y₀ y₁ = (y₀ ∷ u₀ ++ v₀ ≡ y₁ ∷ u₁ ++ v₁)
             + (Σ t ꞉ FA , (y₀ ∷ u₀ ++ v₀ ▷ t) × (y₁ ∷ u₁ ++ v₁ ▷ t))

     δ : type-of IH → ∀ {y₀ y₁} → y₀ ≡ y₁ → Γ y₀ y₁
     δ (inl q)           {y₀} refl = inl (ap (y₀ ∷_) q)
     δ (inr (t , d , e)) {y₀} refl = inr ((y₀ ∷ t) , ∷-▷ y₀ d , ∷-▷ y₀ e)

     γ : Γ y₀ y₁
     γ = δ IH (equal-heads p)

 Church-Rosser : (s t₀ t₁ : FA)
               → s ▷ t₀
               → s ▷ t₁
               → (t₀ ≡ t₁) + (Σ t ꞉ FA , (t₀ ▷ t) × (t₁ ▷ t))
 Church-Rosser s t₀ t₁ (u₀ , v₀ , x₀ , p₀ , q₀) (u₁ , v₁ , x₁ , p₁ , q₁) = γ δ
  where
   δ : (u₀ ++ v₀ ≡ u₁ ++ v₁) + (Σ t ꞉ FA , (u₀ ++ v₀ ▷ t) × (u₁ ++ v₁ ▷ t))
   δ = church-rosser u₀ v₀ u₁ v₁ x₀ x₁ (p₀ ⁻¹ ∙ p₁)

   γ : type-of δ → (t₀ ≡ t₁) + (Σ t ꞉ FA , (t₀ ▷ t) × (t₁ ▷ t))
   γ (inl q)           = inl (q₀ ∙ q ∙ q₁ ⁻¹)
   γ (inr (t , p , q)) = inr (t , transport (_▷ t) (q₀ ⁻¹) p ,
                                  transport (_▷ t) (q₁ ⁻¹) q)
\end{code}

It is noteworthy and remarkable that the above doesn't need decidable
equality on A. We repeat that this construction is due to Fred
Richman.

The following import defines

  _◁▷_       the symmetric closure of _▷_,
  _∿_        the symmetric, reflexive, transitive closure of _▷_,
  _▷*_       the reflexive, transitive closure of _▷_,
  _▷[ n ]_   the n-fold iteration of _▷_.
  _◁▷[ n ]_  the n-fold iteration of _◁▷_.

and its submodule Church-Rosser-consequences develops some useful
consequences of the Church-Rosser property in a general setting.

\begin{code}

 open import SRTclosure
 open Church-Rosser-consequences {𝓤} {𝓤} _▷_ public

\end{code}

The insertion of generators is trivially left cancellable before
quotienting:

\begin{code}

 η-lc : {a b : A} → η a ≡ η b → a ≡ b
 η-lc refl = refl

\end{code}

The following less trivial result, which relies on the Church-Rosser
property, will give that the insertion of generators is injective
after quotienting:

\begin{code}

 η-irreducible : {a : A} {s : FA} → ¬ (η a ▷ s)
 η-irreducible ((x ∷ []) , v , y , () , refl)
 η-irreducible ((x ∷ y ∷ u) , v , z , () , q)

 η-irreducible* : {a : A} {s : FA} → η a ▷* s → η a ≡ s
 η-irreducible* {a} {s} (n , r) = f n r
  where
   f : (n : ℕ) → η a ▷[ n ] s → η a ≡ s
   f zero     refl = refl
   f (succ n) (t , r , i) = 𝟘-elim (η-irreducible r)

 η-identifies-∿-related-points : {a b : A} → η a ∿ η b → a ≡ b
 η-identifies-∿-related-points {a} {b} e = η-lc p
  where
   σ : Σ s ꞉ FA , (η a ▷* s) × (η b ▷* s)
   σ = from-∿ Church-Rosser (η a) (η b) e
   s = pr₁ σ

   p = η a ≡⟨  η-irreducible* (pr₁ (pr₂ σ)) ⟩
       s   ≡⟨ (η-irreducible* (pr₂ (pr₂ σ)))⁻¹ ⟩
       η b ∎

\end{code}

We need to work with the propositional truncation of _∿_ to construct
the free group, but most of the work will be done before truncation.

The following is for reasoning with chains of equivalences _∿_:

\begin{code}

 _∿⟨_⟩_ : (s : FA) {t u : FA} → s ∿ t → t ∿ u → s ∿ u
 _ ∿⟨ p ⟩ q = srt-transitive _▷_ _ _ _ p q

 _∿∎ : (s : FA) → s ∿ s
 _∿∎ _ = srt-reflexive _▷_ _

 infixr 0 _∿⟨_⟩_
 infix  1 _∿∎

 ≡-gives-∿ : {s s' : FA} → s ≡ s' → s ∿ s'
 ≡-gives-∿ {s} refl = srt-reflexive _▷_ s

\end{code}

As discussed above, the group operation before quotienting is simply
concatenation, with the empty list as the neutral element.

Concatenation is a left congruence. We establish this in several
steps:

\begin{code}

 ++-▷-left : (s s' t : FA) → s ▷ s' → s ++ t ▷ s' ++ t
 ++-▷-left s s' t (u , v , x , p , q) = u , (v ++ t) , x , p' , q'
  where
   p' = s ++ t                            ≡⟨ ap (_++ t) p ⟩
        (u ++ [ x ] ++ [ x ⁻ ] ++ v) ++ t ≡⟨ ++-assoc u ([ x ] ++ [ x ⁻ ] ++ v) t ⟩
        u ++ [ x ] ++ [ x ⁻ ] ++ v ++ t   ∎

   q' = s' ++ t       ≡⟨ ap (_++ t) q ⟩
        (u ++ v) ++ t ≡⟨ ++-assoc u v t ⟩
        u ++ v ++ t   ∎

 ++-◁▷-left : (s s' t : FA) → s ◁▷ s' → s ++ t ◁▷ s' ++ t
 ++-◁▷-left s s' t (inl a) = inl (++-▷-left s s' t a)
 ++-◁▷-left s s' t (inr a) = inr (++-▷-left s' s t a)

 ++-iteration-left : (s s' t : FA) (n : ℕ)
                   → s ◁▷[ n ] s'
                   → s ++ t ◁▷[ n ] s' ++ t
 ++-iteration-left s s  t zero     refl        = refl
 ++-iteration-left s s' t (succ n) (u , b , c) = (u ++ t) ,
                                                 ++-◁▷-left s u t b ,
                                                 ++-iteration-left u s' t n c

 ++-cong-left : (s s' t : FA) → s ∿ s' → s ++ t ∿ s' ++ t
 ++-cong-left s s' t (n , a) = n , ++-iteration-left s s' t n a

\end{code}

It is also a right congruence:

\begin{code}

 ∷-◁▷ : (x : X) {s t : FA} → s ◁▷ t → x ∷ s ◁▷ x ∷ t
 ∷-◁▷ x (inl e) = inl (∷-▷ x e)
 ∷-◁▷ x (inr e) = inr (∷-▷ x e)

 ∷-iteration : (x : X) {s t : FA} (n : ℕ)
             → s ◁▷[ n ] t
             → x ∷ s ◁▷[ n ] x ∷ t
 ∷-iteration x zero refl = refl
 ∷-iteration x (succ n) (u , b , c) = (x ∷ u) , ∷-◁▷ x b , ∷-iteration x n c

 ∷-cong : (x : X) {s t : FA} → s ∿ t → x ∷ s ∿ x ∷ t
 ∷-cong x (n , a) = n , ∷-iteration x n a

 ++-cong-right : (s {t t'} : FA) → t ∿ t' → s ++ t ∿ s ++ t'
 ++-cong-right []      e = e
 ++-cong-right (x ∷ s) e = ∷-cong x (++-cong-right s e)

\end{code}

And therefore it is a two-sided congruence:

\begin{code}

 ++-cong-∿ : {s s' t t' : FA} → s ∿ s' → t ∿ t' → s ++ t ∿ s' ++ t'
 ++-cong-∿ {s} {s'} {t} {t'} d e = s ++ t   ∿⟨ ++-cong-left s s' t d ⟩
                                   s' ++ t  ∿⟨ ++-cong-right s' e ⟩
                                   s' ++ t' ∿∎
\end{code}

We now construct the group inverse before quotienting. We reverse the
given list and formally invert all its elements:

\begin{code}

 finv : FA → FA
 finv [] = []
 finv (x ∷ s) = finv s ++ [ x ⁻ ]

\end{code}

It is a congruence, which is proved in several steps:

\begin{code}

 finv-++ : (s t : FA) → finv (s ++ t) ≡ finv t ++ finv s
 finv-++ []      t = []-right-neutral (finv t)
 finv-++ (x ∷ s) t = finv (s ++ t) ++ [ x ⁻ ]      ≡⟨ IH ⟩
                     (finv t ++ finv s) ++ [ x ⁻ ] ≡⟨ a ⟩
                     finv t ++ (finv s ++ [ x ⁻ ]) ∎
  where
   IH = ap (_++ [ x ⁻ ]) (finv-++ s t)
   a  = ++-assoc (finv t) (finv s) [ x ⁻ ]

 finv-▷ : {s t : FA} → s ▷ t → finv s ▷ finv t
 finv-▷ {s} {t} (u , v , y , p , q) = finv v , finv u , y , p' , q'
  where
   p' = finv s                                      ≡⟨ I ⟩
        finv (u ++ [ y ] ++ [ y ⁻ ] ++ v)           ≡⟨ II ⟩
        finv ([ y ] ++ [ y ⁻ ] ++ v) ++ finv u      ≡⟨ III ⟩
        finv (([ y ] ++ [ y ⁻ ]) ++ v) ++ finv u    ≡⟨ IV ⟩
        (finv v ++ [ (y ⁻)⁻ ] ++ [ y ⁻ ]) ++ finv u ≡⟨ V ⟩
        (finv v ++ [ y ] ++ [ y ⁻ ]) ++ finv u      ≡⟨ VI ⟩
        finv v ++ [ y ] ++ [ y ⁻ ] ++ finv u        ∎
    where
     I   = ap finv p
     II  = finv-++ u ([ y ] ++ [ y ⁻ ] ++ v)
     III = ap (λ - → finv - ++ finv u) ((++-assoc [ y ] [ y ⁻ ] v)⁻¹)
     IV  = ap (_++ finv u) (finv-++ ([ y ] ++ [ y ⁻ ]) v)
     V   = ap (λ - → (finv v ++ [ - ] ++ [ y ⁻ ]) ++ finv u) (inv-invol y)
     VI  = ++-assoc (finv v) ([ y ] ++ [ y ⁻ ]) (finv u)

   q' = finv t          ≡⟨ ap finv q ⟩
        finv (u ++ v)   ≡⟨ finv-++ u v ⟩
        finv v ++ finv u ∎

 finv-◁▷ : {s t : FA} → s ◁▷ t → finv s ◁▷ finv t
 finv-◁▷ (inl e) = inl (finv-▷ e)
 finv-◁▷ (inr e) = inr (finv-▷ e)

 finv-iteration : {s t : FA} (n : ℕ)
                → s ◁▷[ n ] t
                → finv s ◁▷[ n ] finv t
 finv-iteration zero refl = refl
 finv-iteration (succ n) (u , b , c) = finv u , finv-◁▷ b , finv-iteration n c

 finv-cong-∿ : {s t : FA} → s ∿ t → finv s ∿ finv t
 finv-cong-∿ (n , a) = n , finv-iteration n a

\end{code}

The inverse really is an inverse:

\begin{code}

 finv-lemma-right : (x : X) → [ x ] ++ [ x ⁻ ] ∿ []
 finv-lemma-right x = srt-extension _▷_ _ [] ([] , [] , x , refl , refl)

 finv-lemma-left : (x : X) → [ x ⁻ ] ++ [ x ] ∿ []
 finv-lemma-left x = srt-extension _▷_ _ _
                      ([] ,
                       [] ,
                       (x ⁻) ,
                       ap (λ - → [ x ⁻ ] ++ [ - ]) ((inv-invol x)⁻¹) , refl)

 finv-right-∿ : (s : FA) → s ++ finv s ∿ []
 finv-right-∿ []      = srt-reflexive _▷_ []
 finv-right-∿ (x ∷ s) = γ
  where
   IH : s ++ finv s ∿ []
   IH = finv-right-∿ s

   γ = [ x ] ++ s ++ finv s ++ [ x ⁻ ]   ∿⟨ I ⟩
       [ x ] ++ (s ++ finv s) ++ [ x ⁻ ] ∿⟨ II ⟩
       [ x ] ++ [ x ⁻ ]                  ∿⟨ III ⟩
       []                                ∿∎
    where
     I   = ≡-gives-∿  (ap (x ∷_) (++-assoc s (finv s) [ x ⁻ ])⁻¹)
     II  = ++-cong-right [ x ] (++-cong-left _ _ _ IH)
     III = finv-lemma-right x

 finv-left-∿ : (s : FA) → finv s ++ s ∿ []
 finv-left-∿ []      = srt-reflexive _▷_ []
 finv-left-∿ (x ∷ s) = γ
  where
   γ = (finv s ++ [ x ⁻ ]) ++ (x ∷ s)    ∿⟨ I ⟩
       finv s ++ ([ x ⁻ ] ++ [ x ] ++ s) ∿⟨ II ⟩
       finv s ++ ([ x ⁻ ] ++ [ x ]) ++ s ∿⟨ III ⟩
       finv s ++ s                       ∿⟨ IV ⟩
       []                                ∿∎
    where
     I   = ≡-gives-∿ (++-assoc (finv s) [ x ⁻ ] (x ∷ s))
     II  = ≡-gives-∿ (ap (finv s ++_) ((++-assoc [ x ⁻ ] [ x ] s)⁻¹))
     III = ++-cong-right (finv s) (++-cong-left _ _ _ (finv-lemma-left x))
     IV  = finv-left-∿ s

\end{code}

The propositional, symmetric, reflexive, transitive closure of _▷_:

\begin{code}

 module free-group-construction-step₁
         (pt : propositional-truncations-exist)
        where

  open PropositionalTruncation pt public

  _∾_ : FA → FA → 𝓤 ̇
  x ∾ y = ∥ x ∿ y ∥

  infix 1 _∾_

  η-identifies-∾-related-points : {a b : A} → is-set A → η a ∾ η b → a ≡ b
  η-identifies-∾-related-points i = ∥∥-rec i η-identifies-∿-related-points

  ++-cong : {s s' t t' : FA} → s ∾ s' → t ∾ t' → s ++ t ∾ s' ++ t'
  ++-cong = ∥∥-functor₂ ++-cong-∿

  finv-cong : {s t : FA} → s ∾ t → finv s ∾ finv t
  finv-cong = ∥∥-functor finv-cong-∿

  finv-right : (s : FA) → s ++ finv s ∾ []
  finv-right s = ∣ finv-right-∿ s ∣

  finv-left : (s : FA) → finv s ++ s ∾ []
  finv-left s = ∣ finv-left-∿ s ∣

\end{code}

To perform the quotient, we assume functional and propositional
extensionality.

\begin{code}

  module free-group-construction-step₂
          (fe : Fun-Ext)
          (pe : Prop-Ext)
        where

\end{code}

We work with quotients constructed in the module UF-Quotient using
functional extensionality and propositional extensionality, and no
higher-inductive types other than propositional truncation:

\begin{code}

   open import UF-Quotient pt fe pe
   open psrt pt _▷_ public

\end{code}

We have that _∾_ is an equivalence relation:

\begin{code}

   ∾-is-equiv-rel : is-equiv-rel _∾_
   ∾-is-equiv-rel = psrt-is-equiv-rel

   -∾- : EqRel FA
   -∾- = _∾_ , ∾-is-equiv-rel

\end{code}

The acronym "psrt" stands for propositional, reflexive, symmetric and
transitive closure of a relation, in this case _▷_.

Our quotients constructed via propositional truncation increase
universe levels:

\begin{code}

   FA/∾ : 𝓤 ⁺ ̇
   FA/∾ = FA / -∾-

   η/∾ : FA → FA/∾
   η/∾ = η/ -∾-

\end{code}

The above function η/∾ is the universal map into the quotient.

We have too many η's now. The insertion of generators of the free
group is obtained by composing the universal map into the quotient
with our original map η : A → FA that inserts the generators into the
freely generated "pre-group" of lists. Because the insertion of
generators into the "real group" is the composition of these two η's,
we use a double η to denote it.

\begin{code}

   ηη : A → FA/∾
   ηη a = η/∾ (η a)

\end{code}

It is noteworthy, and what we wanted to know, constructively, that the
inclusion of generators in the free group is an injection, or a
left-cancellable map:

\begin{code}

   ηη-lc : is-set A → {a b : A} → ηη a ≡ ηη b → a ≡ b
   ηη-lc i p = η-identifies-∾-related-points i
                (η/-relates-identified-points -∾- p)

   ηη-is-embedding : is-set A → is-embedding ηη
   ηη-is-embedding i = lc-maps-into-sets-are-embeddings ηη
                         (ηη-lc i)
                         (quotient-is-set -∾-)

   η/∾-identifies-related-points : {s t : FA} → s ∾ t → η/∾ s ≡ η/∾ t
   η/∾-identifies-related-points = η/-identifies-related-points -∾-

   η/∾--relates-identified-points : {s t : FA} → η/∾ s ≡ η/∾ t → s ∾ t
   η/∾--relates-identified-points = η/-relates-identified-points -∾-

\end{code}

We now need to make FA/∾ into a group. We will use "/" in names to
indicate constructions on the quotient type FA/∾.

\begin{code}

   e/ : FA/∾
   e/ = η/∾ []

   inv/ : FA/∾ → FA/∾
   inv/ = extension₁/ -∾- finv finv-cong

   _·_ : FA/∾ → FA/∾ → FA/∾
   _·_ = extension₂/ -∾- _++_ ++-cong

\end{code}

The following two naturality conditions (in the categorical sense) are
crucial:

\begin{code}

   inv/-natural : (s : FA) → inv/ (η/∾ s) ≡ η/∾ (finv s)
   inv/-natural = naturality/ -∾- finv finv-cong

   ·-natural : (s t : FA) → η/∾ s · η/∾ t ≡ η/∾ (s ++ t)
   ·-natural = naturality₂/ -∾- _++_ ++-cong

\end{code}

Next, to prove the groups laws, we use quotient induction "/-induction".

One can think of elements of FA/∾ as equivalence classes, and of η/∾ s
as the equivalence class of s. Then quotient induction says that in
order to prove a property of equivalence classes, it is enough to
prove it for all equivalence classes of given elements (this is proved
in the module UF-Quotient).

The following proofs rely on the above naturality conditions:

\begin{code}

   ln/ : left-neutral e/ _·_
   ln/ = /-induction -∾- (λ x → e/ · x ≡ x) (λ x → quotient-is-set -∾-) γ
    where
     γ : (s : FA) → η/∾ [] · η/∾ s ≡ η/∾ s
     γ = ·-natural []

   rn/ : right-neutral e/ _·_
   rn/ = /-induction -∾- (λ x → x · e/ ≡ x) (λ x → quotient-is-set -∾-) γ
    where
     γ : (s : FA) → η/∾ s · η/∾ [] ≡ η/∾ s
     γ s = η/∾ s · η/∾ [] ≡⟨ ·-natural s [] ⟩
           η/∾ (s ++ [])  ≡⟨ ap η/∾ ([]-right-neutral s ⁻¹) ⟩
           η/∾ s          ∎

   invl/ : (x : FA/∾) → inv/ x · x ≡ e/
   invl/ = /-induction -∾- (λ x → (inv/ x · x) ≡ e/) (λ x → quotient-is-set -∾-) γ
    where
     γ : (s : FA) → inv/ (η/∾ s) · η/∾ s ≡ e/
     γ s = inv/ (η/∾ s) · η/∾ s  ≡⟨ ap (_· η/∾ s) (inv/-natural s) ⟩
           η/∾ (finv s) · η/∾ s  ≡⟨ ·-natural (finv s) s ⟩
           η/∾ (finv s ++ s)     ≡⟨ η/∾-identifies-related-points (finv-left s) ⟩
           η/∾ []                ≡⟨ refl ⟩
           e/                    ∎

   invr/ : (x : FA/∾) → x · inv/ x ≡ e/
   invr/ = /-induction -∾- (λ x → x · inv/ x ≡ e/) (λ x → quotient-is-set -∾-) γ
    where
     γ : (s : FA) → η/∾ s · inv/ (η/∾ s) ≡ e/
     γ s = η/∾ s · inv/ (η/∾ s)  ≡⟨ ap (η/∾ s ·_) (inv/-natural s) ⟩
           η/∾ s · η/∾ (finv s)  ≡⟨ ·-natural s (finv s) ⟩
           η/∾ (s ++ finv s)     ≡⟨ η/∾-identifies-related-points (finv-right s) ⟩
           η/∾ []                ≡⟨ refl ⟩
           e/                    ∎

   assoc/ : associative _·_
   assoc/ = /-induction -∾- (λ x → ∀ y z → (x · y) · z ≡ x · (y · z))
              (λ x → Π₂-is-prop fe (λ y z → quotient-is-set -∾-))
              (λ s → /-induction -∾- (λ y → ∀ z → (η/∾ s · y) · z ≡ η/∾ s · (y · z))
                       (λ y → Π-is-prop fe (λ z → quotient-is-set -∾-))
                       (λ t → /-induction -∾- (λ z → (η/∾ s · η/∾ t) · z ≡ η/∾ s · (η/∾ t · z))
                                (λ z → quotient-is-set -∾-)
                                (γ s t)))
    where
     γ : (s t u : FA) → (η/∾ s · η/∾ t) · η/∾ u ≡ η/∾ s · (η/∾ t · η/∾ u)
     γ s t u = (η/∾ s · η/∾ t) · η/∾ u ≡⟨ ap (_· η/∾ u) (·-natural s t) ⟩
               η/∾ (s ++ t) · η/∾ u    ≡⟨ ·-natural (s ++ t) u ⟩
               η/∾ ((s ++ t) ++ u)     ≡⟨ ap η/∾ (++-assoc s t u) ⟩
               η/∾ (s ++ (t ++ u))     ≡⟨ (·-natural s (t ++ u))⁻¹ ⟩
               η/∾ s · η/∾ (t ++ u)    ≡⟨ ap (η/∾ s ·_) ((·-natural t u)⁻¹) ⟩
               η/∾ s · (η/∾ t · η/∾ u) ∎
\end{code}

So we have constructed a group with underlying set FA/∾ and a map
ηη : A → FA/∾. We now put everyhing together:

\begin{code}

   𝓕 : Group (𝓤 ⁺)
   𝓕 = (FA/∾ , _·_ , quotient-is-set -∾- , assoc/ , e/ , ln/ , rn/ ,
          (λ x → inv/ x , invl/ x , invr/ x))
\end{code}

To prove that ηη is the universal map of the set A into a group, we
assume another group G with a map f : A → G:

\begin{code}

   module free-group-construction-step₃
            {𝓥 : Universe}
            (G : 𝓥 ̇ )
            (G-is-set : is-set G)
            (e : G)
            (invG : G → G)
            (_⋆_ : G → G → G)
            (G-ln : left-neutral e _⋆_)
            (G-rn : right-neutral e _⋆_)
            (G-invl : (g : G) → invG g ⋆ g ≡ e)
            (G-invr : (g : G) → g ⋆ invG g ≡ e)
            (G-assoc : associative _⋆_)
            (f : A → G)
         where

    𝓖 : Group 𝓥
    𝓖 = (G , _⋆_ ,
         G-is-set , G-assoc , e , G-ln , G-rn ,
         (λ x → invG x , G-invl x , G-invr x))

\end{code}

Our objective is to constructe f' from f making the universality
triangle commute. As a first step in the construction of f', we
construct a map h by induction of lists:

\begin{code}

    h : FA → G
    h [] = e
    h ((₀ , a) ∷ s) = f a ⋆ h s
    h ((₁ , a) ∷ s) = invG (f a) ⋆ h s

\end{code}

We need the following property of h with respect to formal inverses:

\begin{code}

    h⁻ : (x : X) → h ([ x ] ++ [ x ⁻ ]) ≡ e

    h⁻ (₀ , a) = f a ⋆ (invG (f a) ⋆ e)≡⟨ ap (f a ⋆_) (G-rn (invG (f a))) ⟩
                 f a ⋆ invG (f a)      ≡⟨ G-invr (f a) ⟩
                 e                     ∎

    h⁻ (₁ , a) = invG (f a) ⋆ (f a ⋆ e)≡⟨ ap (invG (f a) ⋆_) (G-rn (f a)) ⟩
                 invG (f a) ⋆ f a      ≡⟨ G-invl (f a) ⟩
                 e                     ∎
\end{code}

By construction, the function h is a list homomorphism. It is also a
monoid homomorphism (it would be a group homomorphism if FA were a
group, which it isn't):

\begin{code}

    h-is-hom : (s t : FA) → h (s ++ t) ≡ h s ⋆ h t

    h-is-hom [] t =
     h  t    ≡⟨ (G-ln (h t))⁻¹ ⟩
     e ⋆ h t ∎

    h-is-hom ((₀ , a) ∷ s) t =
     f a ⋆ h (s ++ t)    ≡⟨ ap (f a ⋆_) (h-is-hom s t) ⟩
     f a ⋆ (h s ⋆ h t)   ≡⟨ (G-assoc (f a) (h s) (h t))⁻¹ ⟩
     (f a ⋆ h s) ⋆ h t   ≡⟨ refl ⟩
     h (₀ , a ∷ s) ⋆ h t ∎

    h-is-hom (₁ , a ∷ s) t =
     invG (f a) ⋆ h (s ++ t)  ≡⟨ ap (invG (f a) ⋆_) (h-is-hom s t) ⟩
     invG (f a) ⋆ (h s ⋆ h t) ≡⟨ (G-assoc (invG (f a)) (h s) (h t))⁻¹ ⟩
     (invG (f a) ⋆ h s) ⋆ h t ≡⟨ refl ⟩
     h (₁ , a ∷ s) ⋆ h t      ∎

\end{code}

We also need the following property of the map h in order to construct
our desired group homomorphism f':

\begin{code}

    h-identifies-▷-related-points : {s t : FA} → s ▷ t → h s ≡ h t
    h-identifies-▷-related-points {s} {t} (u , v , y , p , q) =
       h s ≡⟨ ap h p ⟩
       h (u ++ [ y ] ++ [ y ⁻ ] ++ v)   ≡⟨ h-is-hom u ([ y ] ++ [ y ⁻ ] ++ v) ⟩
       h u ⋆ h (y ∷ y ⁻ ∷ v)            ≡⟨ ap (h u ⋆_) (h-is-hom (y ∷ y ⁻ ∷ []) v) ⟩
       h u ⋆ (h (y ∷ (y ⁻) ∷ []) ⋆ h v) ≡⟨ ap (λ - → h u ⋆ (- ⋆ h v)) (h⁻ y) ⟩
       h u ⋆ (e ⋆ h v)                  ≡⟨ ap (h u ⋆_) (G-ln (h v)) ⟩
       h u ⋆ h v                        ≡⟨ (h-is-hom u v)⁻¹ ⟩
       h (u ++ v)                       ≡⟨ ap h (q ⁻¹) ⟩
       h t ∎

    h-identifies-▷*-related-points : {s t : FA} → s ▷* t → h s ≡ h t
    h-identifies-▷*-related-points {s} {t} (n , r) = γ n s t r
     where
      γ : (n : ℕ) (s t : FA) → s ▷[ n ] t → h s ≡ h t
      γ zero s s refl  = refl
      γ (succ n) s t (u , r , i) = h s ≡⟨ h-identifies-▷-related-points r ⟩
                                   h u ≡⟨ γ n u t i ⟩
                                   h t ∎

    h-identifies-∾-related-points : {s t : FA} → s ∾ t → h s ≡ h t
    h-identifies-∾-related-points {s} {t} e = γ
     where
      δ : (Σ u ꞉ FA , (s ▷* u) × (t ▷* u)) → h s ≡ h t
      δ (u , σ , τ) = h s ≡⟨ (h-identifies-▷*-related-points σ) ⟩
                      h u ≡⟨ (h-identifies-▷*-related-points τ)⁻¹ ⟩
                      h t ∎
      γ : h s ≡ h t
      γ = ∥∥-rec G-is-set δ (∥∥-functor (from-∿ Church-Rosser s t) e)

\end{code}

We can then finally construct the unique homorphism f' extending f
using the universal property of quotients, using the above map h:

\begin{code}

    f' : FA/∾ → G
    f' = mediating-map/ -∾- G-is-set h h-identifies-∾-related-points

    f'-/triangle : f' ∘ η/∾ ∼ h
    f'-/triangle = universality-triangle/ -∾- G-is-set h h-identifies-∾-related-points

\end{code}

And from this we get the triangle for the universal property of the
free group:

\begin{code}

    f'-triangle : f' ∘ ηη ∼ f
    f'-triangle a = f' (η/∾ (η a)) ≡⟨ f'-/triangle (η a) ⟩
                    h (η a)        ≡⟨ refl ⟩
                    f a ⋆ e        ≡⟨ G-rn (f a) ⟩
                    f a            ∎

\end{code}

Which is a group homomorphism (rather than merely a monoid
homomorphism like h):

\begin{code}

    f'-is-hom : is-hom 𝓕 𝓖 f'
    f'-is-hom {x} {y} = γ x y
     where
      δ : (s t : FA) → f' (η/∾ s · η/∾ t) ≡ f' (η/∾ s) ⋆ f' (η/∾ t)
      δ s t = f' (η/∾ s · η/∾ t)      ≡⟨ I ⟩
              f' (η/∾ (s ++ t))       ≡⟨ II ⟩
              h (s ++ t)              ≡⟨ III ⟩
              h s ⋆ h t               ≡⟨ IV ⟩
              f' (η/∾ s) ⋆ f' (η/∾ t) ∎
        where
         I   = ap f' (·-natural s t)
         II  = f'-/triangle (s ++ t)
         III = h-is-hom s t
         IV  = ap₂ _⋆_ ((f'-/triangle s)⁻¹) ((f'-/triangle t)⁻¹)

      γ : (x y : FA / -∾-) → f' (x · y) ≡ f' x ⋆ f' y
      γ = /-induction -∾- (λ x → ∀ y → f' (x · y) ≡ f' x ⋆ f' y)
           (λ x → Π-is-prop fe (λ y → G-is-set))
           (λ s → /-induction -∾- (λ y → f' (η/∾ s · y) ≡ f' (η/∾ s) ⋆ f' y)
                   (λ a → G-is-set)
                   (δ s))
\end{code}

Notice that for the following uniqueness property of f' we don't need
to assume that f₀ and f₁ are group homomorphisms:

\begin{code}

    f'-uniqueness-∾ : (f₀ f₁ : FA/∾ → G) → f₀ ∘ η/∾ ∼ h → f₁ ∘ η/∾ ∼ h → f₀ ∼ f₁
    f'-uniqueness-∾ f₀ f₁ p q = at-most-one-mediating-map/ -∾- G-is-set f₀ f₁
                                   (λ s → p s ∙ (q s)⁻¹)

\end{code}

But for this one we do:

\begin{code}

    f'-uniqueness' : (f₀ f₁ : FA/∾ → G)
                  → is-hom 𝓕 𝓖 f₀
                  → is-hom 𝓕 𝓖 f₁
                  → f₀ ∘ ηη ∼ f
                  → f₁ ∘ ηη ∼ f
                  → f₀ ∼ f₁
    f'-uniqueness' f₀ f₁ i₀ i₁ f₀-triangle f₁-triangle = γ
     where
      p : f₀ ∘ ηη ∼ f₁ ∘ ηη
      p x = f₀-triangle x ∙ (f₁-triangle x)⁻¹

      δ : (s : FA) → f₀ (η/∾ s) ≡ f₁ (η/∾ s)
      δ [] = f₀ (η/∾ []) ≡⟨ homs-preserve-unit 𝓕 𝓖 f₀ i₀ ⟩
             e           ≡⟨ (homs-preserve-unit 𝓕 𝓖 f₁ i₁)⁻¹ ⟩
             f₁ (η/∾ []) ∎
      δ ((₀ , a) ∷ s) =
             f₀ (η/∾ (η a ++ s))    ≡⟨ ap f₀ ((·-natural (η a) s)⁻¹) ⟩
             f₀ (ηη a · η/∾ s)      ≡⟨ i₀  ⟩
             f₀ (ηη a) ⋆ f₀ (η/∾ s) ≡⟨ ap₂ _⋆_ (p a) (δ s) ⟩
             f₁ (ηη a) ⋆ f₁ (η/∾ s) ≡⟨ i₁ ⁻¹ ⟩
             f₁ (ηη a · η/∾ s)      ≡⟨ ap f₁ (·-natural (η a) s) ⟩
             f₁ (η/∾ (η a ++ s))    ∎
      δ ((₁ , a) ∷ s) =
             f₀ (η/∾ (finv (η a) ++ s))         ≡⟨ I ⟩
             f₀ (η/∾ (finv (η a)) · η/∾ s)      ≡⟨ II ⟩
             f₀ (η/∾ (finv (η a))) ⋆ f₀ (η/∾ s) ≡⟨ III ⟩
             f₀ (inv/ (ηη a)) ⋆ f₀ (η/∾ s)      ≡⟨ IV ⟩
             invG (f₀ (ηη a)) ⋆ f₀ (η/∾ s)      ≡⟨ IH ⟩
             invG (f₁ (ηη a)) ⋆ f₁ (η/∾ s)      ≡⟨ IV' ⟩
             f₁ (inv/ (ηη a)) ⋆ f₁ (η/∾ s)      ≡⟨ III' ⟩
             f₁ (η/∾ (finv (η a))) ⋆ f₁ (η/∾ s) ≡⟨ II' ⟩
             f₁ (η/∾ (finv (η a)) · η/∾ s)      ≡⟨ I' ⟩
             f₁ (η/∾ (finv (η a) ++ s))         ∎
            where
             I    = ap f₀ ((·-natural (finv (η a)) s)⁻¹)
             II   = i₀
             III  = ap (λ - → f₀ - ⋆ f₀ (η/∾ s)) ((inv/-natural (η a))⁻¹)
             IV   = ap (_⋆ f₀ (η/∾ s)) (homs-preserve-invs 𝓕 𝓖 f₀ i₀ (ηη a))
             IH   = ap₂ (λ - -' → invG - ⋆ -') (p a) (δ s)
             IV'  = ap (_⋆ f₁ (η/∾ s)) ((homs-preserve-invs 𝓕 𝓖 f₁ i₁ (ηη a))⁻¹)
             III' = ap (λ - → f₁ - ⋆ f₁ (η/∾ s)) (inv/-natural (η a))
             II'  = i₁ ⁻¹
             I'   = ap f₁ (·-natural (finv (η a)) s)

      γ : f₀ ∼ f₁
      γ = /-induction -∾- (λ x → f₀ x ≡ f₁ x) (λ x → G-is-set) δ

    f'-uniqueness : ∃! f' ꞉ (⟨ 𝓕 ⟩ → ⟨ 𝓖 ⟩) , is-hom 𝓕 𝓖 f'
                                             × f' ∘ ηη ∼ f
    f'-uniqueness = γ
     where
      c : Σ f' ꞉ (⟨ 𝓕 ⟩ → ⟨ 𝓖 ⟩) , is-hom 𝓕 𝓖 f' × f' ∘ ηη ∼ f
      c = (f' , f'-is-hom , f'-triangle)

      i : is-central _ c
      i (f₀ , f₀-is-hom , f₀-triangle) = to-subtype-≡ a b
       where
        a : (f' : ⟨ 𝓕 ⟩ → ⟨ 𝓖 ⟩) → is-prop (is-hom 𝓕 𝓖 f' × f' ∘ ηη ∼ f)
        a f' = ×-is-prop (being-hom-is-prop fe 𝓕 𝓖 f')
                         (Π-is-prop fe (λ a → group-is-set 𝓖))

        b : f' ≡ f₀
        b = dfunext fe (f'-uniqueness' f' f₀ f'-is-hom f₀-is-hom f'-triangle f₀-triangle)

      γ : ∃! f' ꞉ (⟨ 𝓕 ⟩ → ⟨ 𝓖 ⟩) , is-hom 𝓕 𝓖 f' × f' ∘ ηη ∼ f
      γ = c , i

\end{code}

What we wanted to know is now proved.

We summarize the important parts in the following interface:

\begin{code}

module FreeGroupInterface
        (pt : propositional-truncations-exist)
        (fe : Fun-Ext)
        (pe : Prop-Ext)
        {𝓤 : Universe}
        (A : 𝓤 ̇ )
       where

 open free-group-construction A
 open free-group-construction-step₁ pt
 open free-group-construction-step₂ fe pe

 free-group : Group (𝓤 ⁺)
 free-group = 𝓕

 η-free-group : A → ⟨ free-group ⟩
 η-free-group = ηη

 η-free-group-is-embedding : is-set A → is-embedding η-free-group
 η-free-group-is-embedding = ηη-is-embedding

 module _ ((G , _⋆_ , G-is-set , G-assoc , e , l , r , inversion) : Group 𝓥)
          (f : A → G)
        where

  open free-group-construction-step₃
        G G-is-set e (λ x → pr₁ (inversion x)) _⋆_ l r
        (λ x → pr₁ (pr₂ (inversion x))) (λ x → pr₂ (pr₂ (inversion x))) G-assoc f

  free-group-extension : ⟨ free-group ⟩ → ⟨ 𝓖 ⟩
  free-group-extension = f'

  free-group-is-hom : is-hom free-group 𝓖 free-group-extension
  free-group-is-hom = f'-is-hom

  free-group-triangle : free-group-extension ∘ η-free-group ∼ f
  free-group-triangle = f'-triangle

  extension-to-free-group-uniqueness :

    ∃! f' ꞉ (⟨ free-group ⟩ → ⟨ 𝓖 ⟩) , is-hom free-group 𝓖 f'
                                     × f' ∘ η-free-group ∼ f

  extension-to-free-group-uniqueness = f'-uniqueness

\end{code}

We now package the above into a single theorem.

Notice that we don't need to assume that the type A of
generators is a set to construct the free group and establish its
universal property.

But if A is a set then the universal map η is left-cancellable and
hence an embedding.

\begin{code}

free-groups-exist : propositional-truncations-exist
                  → Fun-Ext
                  → Prop-Ext
                  → (A : 𝓤 ̇ )
                  → Σ 𝓕 ꞉ Group (𝓤 ⁺)
                  , Σ η ꞉ (A → ⟨ 𝓕 ⟩)
                  , ((𝓖 : Group 𝓥) (f : A → ⟨ 𝓖 ⟩)
                        → ∃! f' ꞉ (⟨ 𝓕 ⟩ → ⟨ 𝓖 ⟩) , is-hom 𝓕 𝓖 f' × f' ∘ η ∼ f)
                  × (is-set A → is-embedding η)

free-groups-exist pt fe pe A = free-group A  ,
                               η-free-group A ,
                               extension-to-free-group-uniqueness A ,
                               η-free-group-is-embedding A
 where
  open FreeGroupInterface pt fe pe

\end{code}

Notice that the free group construction increases the universe level,
but the universal property eliminates into any universe.
