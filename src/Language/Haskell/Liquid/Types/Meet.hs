-- | This code has various wrappers around `meet` and `strengthen`
--   that are here so that we can throw decent error messages if
--   they fail. The module depends on `RefType` and `UX.Tidy`.

module Language.Haskell.Liquid.Types.Meet
     ( meetVarTypes ) where

import           SrcLoc
import           Text.PrettyPrint.HughesPJ (text, Doc)
import qualified Language.Fixpoint.Types as F
import           Language.Haskell.Liquid.Types
import           Language.Haskell.Liquid.Types.RefType
import           Language.Haskell.Liquid.UX.Tidy
import           TyCon                                  hiding (tyConName)

meetVarTypes :: F.TCEmb TyCon -> Doc -> (SrcSpan, SpecType) -> (SrcSpan, SpecType) -> SpecType
meetVarTypes emb v hs lq = meetError emb err hsT lqT
  where
    (hsSp, hsT)      = hs
    (lqSp, lqT)      = lq
    err              = ErrMismatch lqSp v (text "meetVarTypes") hsD lqD hsSp
    hsD              = F.pprint ({- toRSort -} hsT)
    lqD              = F.pprint ({- toRSort -} lqT)

meetError :: F.TCEmb TyCon -> Error -> SpecType -> SpecType -> SpecType
meetError _emb e t t'
  -- // | meetable emb t t'
  | True              = t `F.meet` t'
  | otherwise         = panicError e

_meetable :: F.TCEmb TyCon -> SpecType -> SpecType -> Bool
_meetable _emb t1 t2 = F.notracepp ("meetable: " ++  showpp (s1, t1, s2, t2)) (s1 == s2)
  where
    s1              = tx t1
    s2              = tx t2
    tx              =  rTypeSort _emb . toRSort
