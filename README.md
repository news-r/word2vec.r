
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
[![Travis build status](https://travis-ci.org/news-r/word2vec.r.svg?branch=master)](https://travis-ci.org/news-r/word2vec.r) <!-- badges: end -->

word2vec.r
==========

`word2vec.r` is an R wrapper to the `Word2Vec.jl` Julia package.

Installation
------------

Being a wrapper to a [Julia](https://julialang.org/) package, `word2vec.r` requires the latter to be installed.

You can install the package from Github with:

``` r
# install.packages("remotes")
remotes::install_github("news-r/word2vec.r")
```

Examples
--------

You *must* run `setup_word2vec` at the begining of every session, you will otherwise encounter errors and be prompted to do so.

``` r
library(word2vec.r)

# setup word2vec Julia dependency
setup_word2vec()
```

The package comes with a dataset, [Macbeth by Shakespeare](https://en.wikipedia.org/wiki/Macbeth). However, being a corpus of 17,319 words it is not lazyly loaded and needs to be imported manually with the `data` function.

``` r
data("macbeth", package = "word2vec.r")
```

### Word Vectors

With data we can train a model and extract the vectors.

``` r
model_path <- word2vec(macbeth) # train model
model <- word_vectors(model_path) # get word vectors
```

There are then a multitude of functions one can use on the model.

-   `get_vector`
-   `vocabulary`
-   `in_vocabulary`
-   `size`
-   `index`
-   `cosine`
-   `cosine_similar_words`
-   `similarity`
-   `analogy`
-   `analogy_words`

All are well documented and have examples, visit their respective man pages with i.e.: `?get_vector`. Note that since all the functions listed above require the output of `word_vectors` (the `model` object in our case). Therefore a convenient reference class also exists.

**Functional**

``` r
# words similar to king
cosine_similar_words(model, "king", 5L)
#> [1] "king"  "come"  "yet"   "from"  "rosse"

# size of model
size(model)
#> # A tibble: 1 x 2
#>   length words
#>    <int> <int>
#> 1    100   511
```

**Reference Class**

``` r
wv <- WordVectors$new(model)
wv$get_vector("macbeth")
#>   [1]  0.0635810543 -0.0995174434  0.0869721416 -0.1318403260  0.0569811867
#>   [6] -0.0399884187  0.0343900688  0.0143089687 -0.0467951006  0.2164154317
#>  [11]  0.0610427910  0.1830144335 -0.1445292489 -0.0726938121  0.0006266667
#>  [16]  0.1992010085  0.1222292030  0.0540336033  0.1390457958  0.1374453782
#>  [21] -0.0337686682  0.0476056023  0.1241288312 -0.1659182583 -0.0049822154
#>  [26] -0.0962433614  0.0072499924  0.0149581360  0.1686743469  0.0710407334
#>  [31] -0.0664884238 -0.0163244512 -0.1612941381  0.0514158696 -0.0456609728
#>  [36] -0.0034387675  0.1001402802 -0.0912103998  0.0375420728 -0.0653547747
#>  [41] -0.0100630507  0.1447078178 -0.1385450370 -0.1403182787  0.0586591597
#>  [46]  0.1127875529 -0.0199422664 -0.0215015126 -0.0591015126 -0.0602696308
#>  [51] -0.0214881080 -0.0832241101  0.0610566743 -0.0564330329 -0.0138986911
#>  [56] -0.0326216145  0.1612026993 -0.0790026076 -0.0185630252 -0.2189197047
#>  [61]  0.0837808811 -0.1314051541 -0.0284982531 -0.0630860403 -0.0707558849
#>  [66]  0.1748251592  0.1121374281 -0.0708028012  0.1577553146  0.0848757525
#>  [71]  0.0021059638 -0.0237592361  0.0931023683 -0.1055610186 -0.1658708633
#>  [76] -0.0121311943 -0.1720872626  0.0122216756 -0.1929750345 -0.1492912453
#>  [81]  0.0252576827  0.0249398014 -0.0468357933 -0.0819583296  0.0746853578
#>  [86]  0.1879459028  0.0511540005 -0.0552424141  0.2260399594 -0.0589406570
#>  [91] -0.0398457551  0.0803224854  0.0177103947  0.0343560785  0.0489676089
#>  [96]  0.0870554419  0.0657722333  0.1658368730  0.0089542959 -0.0574345506
wv$cosine("rosse")
#> # A tibble: 10 x 2
#>    index cosine
#>    <int>  <dbl>
#>  1    67  1    
#>  2   106  1.000
#>  3    51  1.000
#>  4   115  1.000
#>  5    56  1.000
#>  6    54  1.000
#>  7     4  1.000
#>  8    13  1.000
#>  9    21  1.000
#> 10     3  1.000
```

### Word Clusters

You can also cluster words.

``` r
model_path <- word2clusters(macbeth, classes = 50L) # train model
model <- word_clusters(model_path)
```

Then again, we provide both a functional API and a reference class.

-   `vocabulary`
-   `in_vocabulary`
-   `index`
-   `get_cluster`
-   `clusters`
-   `get_words`

**Functional**

``` r
get_cluster(model, "king")
#> [1] 5
get_cluster(model, "macbeth")
#> [1] 44
```

**Reference Class**

``` r
wc <- WordClusters$new(model)
wc$get_words(4L)
#>  [1] "to"       "i"        "thy"      "know"     "too"      "comes"   
#>  [7] "stand"    "himselfe" "daggers"  "power"    "fall"     "hearke"  
#> [13] "chance"
wc$vocabulary("rosse")
#>   [1] "</s>"       "the"        "and"        "to"         "i"         
#>   [6] "of"         "a"          "that"       "d"          "you"       
#>  [11] "my"         "in"         "is"         "not"        "it"        
#>  [16] "with"       "his"        "be"         "macb"       "s"         
#>  [21] "your"       "our"        "haue"       "but"        "what"      
#>  [26] "me"         "he"         "for"        "this"       "all"       
#>  [31] "so"         "thou"       "him"        "as"         "we"        
#>  [36] "enter"      "which"      "are"        "will"       "they"      
#>  [41] "shall"      "no"         "on"         "then"       "macbeth"   
#>  [46] "vpon"       "their"      "thee"       "do"         "macd"      
#>  [51] "from"       "vs"         "th"         "yet"        "thy"       
#>  [56] "king"       "come"       "there"      "now"        "would"     
#>  [61] "at"         "hath"       "more"       "who"        "by"        
#>  [66] "good"       "rosse"      "was"        "t"          "them"      
#>  [71] "lady"       "time"       "if"         "like"       "her"       
#>  [76] "should"     "st"         "did"        "let"        "say"       
#>  [81] "when"       "where"      "were"       "make"       "banquo"    
#>  [86] "doe"        "o"          "lord"       "or"         "tis"       
#>  [91] "1"          "must"       "done"       "selfe"      "ile"       
#>  [96] "know"       "may"        "feare"      "man"        "had"       
#> [101] "wife"       "night"      "how"        "well"       "too"       
#> [106] "why"        "one"        "great"      "see"        "exeunt"    
#> [111] "am"         "speake"     "sir"        "lenox"      "an"        
#> [116] "out"        "can"        "mine"       "vp"         "heere"     
#> [121] "mal"        "thane"      "nor"        "looke"      "giue"      
#> [126] "banq"       "such"       "those"      "blood"      "these"     
#> [131] "things"     "most"       "sleepe"     "hand"       "2"         
#> [136] "scena"      "againe"     "here"       "cawdor"     "before"    
#> [141] "la"         "3"          "nature"     "till"       "cannot"    
#> [146] "death"      "life"       "doct"       "art"        "day"       
#> [151] "loue"       "still"      "shew"       "both"       "ha"        
#> [156] "heart"      "take"       "heare"      "macduffe"   "within"    
#> [161] "men"        "though"     "call"       "way"        "owne"      
#> [166] "she"        "some"       "sey"        "worthy"     "strange"   
#> [171] "nothing"    "euery"      "knock"      "put"        "poore"     
#> [176] "could"      "father"     "son"        "ere"        "ayre"      
#> [181] "bloody"     "name"       "goe"        "other"      "downe"     
#> [186] "thought"    "heauen"     "borne"      "malc"       "haile"     
#> [191] "leaue"      "god"        "against"    "without"    "wee"       
#> [196] "whose"      "murther"    "dead"       "euer"       "deed"      
#> [201] "three"      "hee"        "new"        "cry"        "comes"     
#> [206] "noble"      "thus"       "about"      "each"       "much"      
#> [211] "none"       "pray"       "thinke"     "malcolme"   "made"      
#> [216] "exit"       "neuer"      "dare"       "sword"      "hands"     
#> [221] "scotland"   "honor"      "into"       "beare"      "onely"     
#> [226] "euen"       "eye"        "keepe"      "bed"        "first"     
#> [231] "place"      "two"        "double"     "eyes"       "beene"     
#> [236] "very"       "hang"       "liue"       "peace"      "once"      
#> [241] "kings"      "liues"      "away"       "finde"      "face"      
#> [246] "whom"       "welcome"    "full"       "hold"       "hence"     
#> [251] "else"       "hell"       "morrow"     "seruant"    "stand"     
#> [256] "fight"      "go"         "wood"       "gent"       "tell"      
#> [261] "words"      "thine"      "mac"        "grace"      "sight"     
#> [266] "houre"      "friends"    "being"      "duncan"     "thoughts"  
#> [271] "murth"      "old"        "flye"       "l"          "seyward"   
#> [276] "woman"      "thunder"    "report"     "head"       "get"       
#> [281] "house"      "nights"     "royall"     "hope"       "rest"      
#> [286] "vnder"      "lesse"      "highnesse"  "further"    "light"     
#> [291] "false"      "tongue"     "businesse"  "macduff"    "off"       
#> [296] "bring"      "last"       "minde"      "lye"        "many"      
#> [301] "fleans"     "tyrant"     "witches"    "set"        "himselfe"  
#> [306] "fell"       "present"    "hast"       "gone"       "earth"     
#> [311] "truth"      "children"   "re"         "true"       "might"     
#> [316] "giuen"      "feares"     "enough"     "thing"      "knowne"    
#> [321] "sorrow"     "rather"     "almost"     "dayes"      "does"      
#> [326] "heard"      "drinke"     "bell"       "knocking"   "best"      
#> [331] "lords"      "any"        "england"    "better"     "sonne"     
#> [336] "doctor"     "dunsinane"  "meet"       "anon"       "donalbaine"
#> [341] "state"      "fortune"    "master"     "sisters"    "seeme"     
#> [346] "breath"     "throw"      "bid"        "desire"     "comming"   
#> [351] "shake"      "goes"       "trouble"    "while"      "daggers"   
#> [356] "oh"         "ban"        "kill"       "fled"       "sit"       
#> [361] "gracious"   "power"      "mur"        "knowes"     "lost"      
#> [366] "faire"      "through"    "alarum"     "attendants" "whence"    
#> [371] "another"    "helpe"      "angus"      "cold"       "vse"       
#> [376] "doth"       "seene"      "shalt"      "withall"    "stay"      
#> [381] "word"       "forth"      "deepe"      "dy"         "left"      
#> [386] "themselues" "thanes"     "fall"       "lyes"       "after"     
#> [391] "mortall"    "lay"        "powre"      "round"      "fate"      
#> [396] "messenger"  "please"     "natures"    "makes"      "gentle"    
#> [401] "late"       "chamber"    "since"      "world"      "hearke"    
#> [406] "little"     "faith"      "english"    "command"    "thence"    
#> [411] "rise"       "colours"    "neere"      "issue"      "send"      
#> [416] "wisedome"   "tyrants"    "y"          "seyton"     "actus"     
#> [421] "prima"      "foule"      "secunda"    "meeting"    "friend"    
#> [426] "together"   "bad"        "toth"       "comfort"    "ouer"      
#> [431] "seemes"     "terrible"   "point"      "ten"        "former"    
#> [436] "title"      "tertia"     "husband"    "thither"    "thrice"    
#> [441] "charme"     "farre"      "women"      "sound"      "indeed"    
#> [446] "stands"     "water"      "takes"      "reason"     "thankes"   
#> [451] "home"       "crowne"     "harme"      "honest"     "chance"    
#> [456] "braine"     "toward"     "free"       "flourish"   "saw"       
#> [461] "part"       "receiue"    "duties"     "safe"       "hither"    
#> [466] "sonnes"     "care"       "perfect"    "came"       "attend"    
#> [471] "high"       "spirits"    "eare"       "fill"       "purpose"   
#> [476] "ring"       "darke"      "innocent"   "hostesse"   "pleasure"  
#> [481] "returne"    "strong"     "pale"       "strike"     "horror"    
#> [486] "bold"       "fire"       "em"         "amen"       "feast"     
#> [491] "faces"      "porter"     "said"       "selues"     "horses"    
#> [496] "certaine"   "slaine"     "meanes"     "bene"       "graue"     
#> [501] "cause"      "worst"      "health"     "backe"      "len"       
#> [506] "answer"     "country"    "cauldron"   "mother"     "soldiers"  
#> [511] "ment"
```
