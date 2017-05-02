{-@ LIQUID "--higherorder"     @-}
{-@ LIQUID "--totality"        @-}
{-@ LIQUID "--exactdc"         @-}
{-# LANGUAGE RankNTypes #-}
module GenericProofs.VerifiedFunctor (VerifiedFunctor(..)) where

import Language.Haskell.Liquid.ProofCombinators

import GenericProofs.Iso

{-@ axiomatize _identity @-}
_identity :: a -> a
_identity x = x
{-# INLINE _identity #-}

{-@ axiomatize _compose @-}
_compose :: (b -> c) -> (a -> b) -> a -> c
_compose f g x = f (g x)
{-# INLINE _compose #-}

{-@
data VerifiedFunctor m = VerifiedFunctor {
    fmap        :: forall a b. (a -> b) -> m a -> m b
  , fmapId      :: forall a. x:m a -> { fmap _identity x == x }
  , fmapCompose :: forall a b c. f:(b -> c) -> g:(a -> b) -> x:m a
                -> { fmap (_compose f g) x == _compose (fmap f) (fmap g) x }
  }
@-}
data VerifiedFunctor m = VerifiedFunctor {
    fmap        :: forall a b. (a -> b) -> m a -> m b
  , fmapId      :: forall a. m a -> Proof
  , fmapCompose :: forall a b c. (b -> c) -> (a -> b) -> m a -> Proof
  }

{-
{-@ axiomatize functorInvFmap @-}
functorInvFmap :: (forall a. f a -> g a)
               -> (forall a. g a -> f a)
               -> (forall a b. (a -> b) -> f a -> f b)
               -> (p -> q)
               -> g p
               -> g q
functorInvFmap f t fmapF h x = f (fmapF h (t x))

{-@ functorInvFmapId :: f:(forall a. f a -> g a)
                     -> t:(forall a. g a -> f a)
                     -> fot:(forall a. x:(g a) -> { f (t x) == x })
                     -> fmapF:(forall a b. (a -> b) -> f a -> f b)
                     -> fmapFId:(forall a. x:(f a) -> { fmapF _identity x == x })
                     -> y:(g p)
                     -> { functorInvFmap f t fmapF _identity y == y }
@-}
functorInvFmapId :: (forall a. f a -> g a)
                 -> (forall a. g a -> f a)
                 -> (forall a. g a -> Proof)
                 -> (forall a b. (a -> b) -> f a -> f b)
                 -> (forall a. f a -> Proof)
                 -> g p
                 -> Proof
functorInvFmapId f t fot fmapF fmapFId y
  =   functorInvFmap f t fmapF _identity y
  ==. f (fmapF _identity (t y))
  ==. f (t y) ? fmapFId (t y)
  ==. y ? fot y
  *** QED

{-@ functorInvFmapCompose :: fro:(forall a. f a -> g a)
                          -> t:(forall a. g a -> f a)
                          -> tof:(forall a. x:(f a) -> { t (fro x) == x })
                          -> fmapF:(forall a b. (a -> b) -> f a -> f b)
                          -> fmapFCompose:(forall a b c. f':(b -> c) -> g':(a -> b) -> x:(f a) -> { fmapF (_compose f' g') x == _compose (fmapF f') (fmapF g') x })
                          -> f:(q -> r)
                          -> g:(p -> q)
                          -> y:(g p)
                          -> { functorInvFmap fro t fmapF (_compose f g) y == _compose (functorInvFmap fro t fmapF f) (functorInvFmap fro t fmapF g) y }
@-}
functorInvFmapCompose :: (forall a. f a -> g a)
                      -> (forall a. g a -> f a)
                      -> (forall a. f a -> Proof)
                      -> (forall a b. (a -> b) -> f a -> f b)
                      -> (forall a b c. (b -> c) -> (a -> b) -> f a -> Proof)
                      -> (q -> r)
                      -> (p -> q)
                      -> g p
                      -> Proof
functorInvFmapCompose fro t tof fmapF fmapFCompose f g y
  =   functorInvFmap fro t fmapF (_compose f g) y
  ==. fro (fmapF (_compose f g) (t y))
  ==. fro (_compose (fmapF f) (fmapF g) (t y)) ? fmapFCompose f g (t y)
  ==. fro (fmapF f (fmapF g (t y)))
  ==. fro (fmapF f (t (fro (fmapF g (t y))))) ? tof (fmapF g (t y))
  ==. functorInvFmap fro t fmapF f (fro (fmapF g (t y)))
  ==. functorInvFmap fro t fmapF f (functorInvFmap fro t fmapF g y)
  ==. _compose (functorInvFmap fro t fmapF f) (functorInvFmap fro t fmapF g) y
  *** QED

vfunctorInv :: (forall a. f a -> g a) -> (forall a. g a -> f a)
            -> (forall a. g a -> Proof) -> (forall a. f a -> Proof)
            -> VerifiedFunctor f -> VerifiedFunctor g
vfunctorInv f t fot tof (VerifiedFunctor fmapF fmapFId fmapFCompose)
  = VerifiedFunctor (functorInvFmap        f t fmapF)
                    (functorInvFmapId      f t fot fmapF fmapFId)
                    (functorInvFmapCompose f t tof fmapF fmapFCompose)

vfunctorIso :: Iso1 f g -> VerifiedFunctor f -> VerifiedFunctor g
vfunctorIso (Iso1 t f tof fot) = vfunctorInv t f tof fot
{-# INLINE vfunctorIso #-}
-}
