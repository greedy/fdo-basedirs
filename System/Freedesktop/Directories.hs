{- |
Module      :   System/Freedesktop/Directories.hs
Description :   Implements freedesktop.org basedir specification
Copyright   :   (c) Geoffrey Reedy
License     :   BSD3

Maintainer  :   geoff@programmer-monk.net
Stability   :   provisional
Portability :   portable

This module provides the directories and search paths specified by the XDG Base
Directory Specification at
<http://www.freedesktop.org/wiki/Specifications/basedir-spec>

-}
module System.Freedesktop.Directories (
  -- | The XDG Base Directory Specification is based on the following concepts:
    dataHome
  , configHome
  , dataDirs
  , configDirs
  , cacheHome
  ) where

import System.FilePath.Posix
import System.Environment
import System.Directory
import System.IO.Error

fallbackTo :: IO a -> IO a -> IO a
fallbackTo a b = catch a (\e -> if isDoesNotExistError e then b else ioError e)

home :: FilePath -> IO FilePath
home p = getHomeDirectory >>= return . (</>p)

searchPath :: IO FilePath -> IO [FilePath]
searchPath p = p >>= return . splitSearchPath

-- | There is a single base directory relative to which user-specific data files should be written.
dataHome :: IO FilePath
dataHome = (getEnv "XDG_DATA_HOME"
            `fallbackTo` home ".local/share") >>= return . normalise

-- | There is a single base directory relative to which user-specific configuration files should be written.
configHome :: IO FilePath
configHome = (getEnv "XDG_CONFIG_HOME"
              `fallbackTo` home ".config") >>= return . normalise

-- | There is a set of preference ordered base directories relative to which data files should be searched.
dataDirs :: IO [FilePath]
dataDirs = (searchPath (getEnv "XDG_DATA_DIRS")
            `fallbackTo` return ["/usr/local/share", "/usr/share"]) >>= return . map normalise

-- | There is a set of preference ordered base directories relative to which configuration files should be searched.
configDirs :: IO [FilePath]
configDirs = (searchPath (getEnv "XDG_CONFIG_DIRS")
              `fallbackTo` return ["/etc/xdg"]) >>= return . map normalise

-- | There is a single base directory relative to which user-specific non-essential (cached) data should be written.
cacheHome :: IO FilePath
cacheHome = (getEnv "XDG_CACHE_HOME"
             `fallbackTo` home ".cache") >>= return . normalise
