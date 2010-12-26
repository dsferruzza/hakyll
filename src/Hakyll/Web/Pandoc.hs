-- | Module exporting pandoc bindings
--
module Hakyll.Web.Pandoc
    ( readPandoc
    , readPandocWith
    , writePandoc
    , writePandocWith
    , targetReadPandoc
    , targetReadPandocWith
    , targetRenderPandoc
    , targetRenderPandocWith
    , defaultParserState
    , defaultWriterOptions
    ) where

import Control.Applicative ((<$>), (<*>))

import Text.Pandoc (Pandoc)
import qualified Text.Pandoc as P

import Hakyll.Web.FileType
import Hakyll.Core.Target

-- | Read a string using pandoc, with the default options
--
readPandoc :: FileType       -- ^ File type, determines how parsing happens
           -> String         -- ^ String to read
           -> Pandoc         -- ^ Resulting document
readPandoc = readPandocWith defaultParserState

-- | Read a string using pandoc, with the supplied options
--
readPandocWith :: P.ParserState  -- ^ Parser options
               -> FileType       -- ^ File type, determines how parsing happens
               -> String         -- ^ String to read
               -> Pandoc         -- ^ Resulting document
readPandocWith state fileType' = case fileType' of
    Html              -> P.readHtml state
    LaTeX             -> P.readLaTeX state
    LiterateHaskell t -> readPandocWith state {P.stateLiterateHaskell = True} t
    Markdown          -> P.readMarkdown state
    Rst               -> P.readRST state
    t                 -> error $
        "readPandoc: I don't know how to read " ++ show t

-- | Write a document (as HTML) using pandoc, with the default options
--
writePandoc :: Pandoc           -- ^ Document to write
            -> String           -- ^ Resulting HTML
writePandoc = writePandocWith defaultWriterOptions

-- | Write a document (as HTML) using pandoc, with the supplied options
--
writePandocWith :: P.WriterOptions  -- ^ Writer options for pandoc
                -> Pandoc           -- ^ Document to write
                -> String           -- ^ Resulting HTML
writePandocWith = P.writeHtmlString

-- | Read the resource using pandoc
--
targetReadPandoc :: TargetM a Pandoc
targetReadPandoc = targetReadPandocWith defaultParserState

-- | Read the resource using pandoc
--
targetReadPandocWith :: P.ParserState -> TargetM a Pandoc
targetReadPandocWith state =
    readPandocWith state <$> getFileType <*> getResourceString

-- | Render the resource using pandoc
--
targetRenderPandoc :: TargetM a String
targetRenderPandoc =
    targetRenderPandocWith defaultParserState defaultWriterOptions

-- | Render the resource using pandoc
--
targetRenderPandocWith :: P.ParserState -> P.WriterOptions -> TargetM a String
targetRenderPandocWith state options =
    writePandocWith options <$> targetReadPandocWith state

-- | The default reader options for pandoc parsing in hakyll
--
defaultParserState :: P.ParserState
defaultParserState = P.defaultParserState
    { -- The following option causes pandoc to read smart typography, a nice
      -- and free bonus.
      P.stateSmart = True
    }

-- | The default writer options for pandoc rendering in hakyll
--
defaultWriterOptions :: P.WriterOptions
defaultWriterOptions = P.defaultWriterOptions
    { -- This option causes literate haskell to be written using '>' marks in
      -- html, which I think is a good default.
      P.writerLiterateHaskell = True
    }