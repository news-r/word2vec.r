
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/news-r/word2vec.r.svg?branch=master)](https://travis-ci.org/news-r/word2vec.r)
<!-- badges: end -->

# word2vec.r

`word2vec.r` is an R wrapper to the `Word2Vec.jl` Julia package.

## Installation

Being a wrapper to a [Julia](https://julialang.org/) package,
`word2vec.r` requires the latter to be installed.

You can install the package from Github with:

``` r
# install.packages("remotes")
remotes::install_github("news-r/word2vec.r")
```

## Examples

You *must* run `setup_word2vec` at the begining of every session, you
will otherwise encounter errors and be prompted to do so.

``` r
library(word2vec.r)

# setup word2vec Julia dependency
setup_word2vec()
#> Julia version 1.1.1 at location /Applications/Julia-1.1.app/Contents/Resources/julia/bin will be used.
#> Loading setup script for JuliaCall...
#> Finish loading setup script for JuliaCall.
```

The package comes with a dataset, [Macbeth by
Shakespeare](https://en.wikipedia.org/wiki/Macbeth). However, being a
corpus of 17,319 words it is not lazyly loaded and needs to be imported
manually with the `data` function.

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

  - `get_vector`
  - `vocabulary`
  - `in_vocabulary`
  - `size`
  - `index`
  - `cosine`
  - `cosine_similar_words`
  - `similarity`
  - `analogy`
  - `analogy_words`

All are well documented and have examples, visit their respective man
pages with i.e.: `?get_vector`. Note that since all the functions listed
above require the output of `word_vectors` (the `model` object in our
case). Therefore a convenient reference class also exists.

**Functional**

``` r
# words similar to king
cosine_similar_words(model, "king", 5L)
#> [1] "king"  "rosse" "thy"   "me"    "out"

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
#>   [1] -0.0067439286 -0.0710750896  0.0807698409 -0.1501817158  0.0814020979
#>   [6] -0.0683351644  0.0061051356  0.0664431868 -0.0130708551  0.2644995184
#>  [11]  0.0873477530  0.1845654244 -0.1658182006 -0.1329255900  0.0146613015
#>  [16]  0.2192563288  0.0728642329  0.0522276459  0.1044500630  0.0791628365
#>  [21] -0.0213799573  0.1065328942  0.1595026033 -0.1875519777 -0.0154155653
#>  [26] -0.1182808465 -0.0055229886  0.0364016147  0.1294806395  0.0952415961
#>  [31] -0.1599479283 -0.0360538952 -0.2224446292  0.0717060393 -0.0614378558
#>  [36] -0.0092672916  0.1202068118 -0.0859398812  0.0705774760 -0.0319557723
#>  [41] -0.0718306606  0.1621701959 -0.0766721538 -0.1317286157  0.1092061514
#>  [46]  0.0785898400 -0.0331745336 -0.0111496830 -0.0892053073 -0.0932585491
#>  [51] -0.0539209267 -0.0518433244  0.0343113760 -0.0492193057 -0.0608709597
#>  [56] -0.0393319578  0.1423837352 -0.0174238852 -0.0043046631 -0.1805322266
#>  [61]  0.0592417325 -0.0781907033 -0.0002444494 -0.0356560657 -0.0860858536
#>  [66]  0.1953129205  0.0453943910 -0.1692827594  0.1718013293  0.0399053900
#>  [71]  0.0016897949  0.0100185052  0.0786630441 -0.0731287263 -0.2057292552
#>  [76] -0.0038976831 -0.1377540110 -0.0176792281 -0.0850553315 -0.1061232998
#>  [81]  0.0196378737  0.0142447353  0.0624701209 -0.0858644984  0.0228135377
#>  [86]  0.1458374005  0.0207455216 -0.0126582105  0.1609954442 -0.0321723345
#>  [91]  0.0032048585  0.0586970591  0.0041316748  0.0561092067  0.1142088680
#>  [96]  0.1191736752  0.0096590208  0.1319809084 -0.0083727200 -0.1074322590
wv$cosine("rosse")
#> # A tibble: 10 x 2
#>    index cosine
#>    <int>  <dbl>
#>  1    67  1    
#>  2    56  1.000
#>  3    51  1.000
#>  4    91  1.000
#>  5     9  1.000
#>  6    89  1.000
#>  7    48  1.000
#>  8    58  1.000
#>  9    34  1.000
#> 10    50  1.000
```

### Word Clusters

You

``` r
model_path <- word2clusters(macbeth, classes = 50L) # train model
model <- word_clusters(model_path)
```

**Functional**

``` r
get_cluster(model, "king")
#> [1] 5
get_cluster(model, "macbeth")
#> [1] 45
```

**Reference Class**

``` r
wc <- WordClusters$new(model)
wc$get_words(4L)
#>  [1] "to"         "i"          "thy"        "know"       "too"       
#>  [6] "about"      "eyes"       "doctor"     "while"      "master"    
#> [11] "themselues" "vse"        "worst"
wc$vocabulary("rosse")
#>   [1] "</s>"       "the"        "and"        "to"         "i"         
#>   [6] "of"         "a"          "that"       "d"          "you"       
#>  [11] "my"         "in"         "is"         "not"        "it"        
#>  [16] "with"       "his"        "macb"       "be"         "s"         
#>  [21] "your"       "our"        "haue"       "but"        "what"      
#>  [26] "me"         "he"         "for"        "this"       "all"       
#>  [31] "so"         "him"        "thou"       "as"         "we"        
#>  [36] "enter"      "which"      "are"        "will"       "they"      
#>  [41] "shall"      "no"         "on"         "then"       "their"     
#>  [46] "macbeth"    "vpon"       "thee"       "do"         "macd"      
#>  [51] "yet"        "from"       "vs"         "th"         "thy"       
#>  [56] "king"       "come"       "now"        "there"      "would"     
#>  [61] "at"         "hath"       "more"       "who"        "good"      
#>  [66] "by"         "rosse"      "was"        "lady"       "them"      
#>  [71] "t"          "time"       "if"         "her"        "like"      
#>  [76] "should"     "did"        "let"        "st"         "say"       
#>  [81] "when"       "make"       "were"       "banquo"     "where"     
#>  [86] "lord"       "doe"        "o"          "or"         "tis"       
#>  [91] "1"          "must"       "ile"        "may"        "done"      
#>  [96] "know"       "feare"      "selfe"      "wife"       "how"       
#> [101] "had"        "man"        "night"      "well"       "too"       
#> [106] "why"        "one"        "great"      "see"        "exeunt"    
#> [111] "am"         "speake"     "sir"        "lenox"      "an"        
#> [116] "out"        "can"        "vp"         "mine"       "heere"     
#> [121] "thane"      "mal"        "those"      "looke"      "nor"       
#> [126] "such"       "blood"      "banq"       "giue"       "most"      
#> [131] "these"      "sleepe"     "hand"       "things"     "2"         
#> [136] "scena"      "here"       "la"         "before"     "againe"    
#> [141] "cawdor"     "till"       "life"       "cannot"     "3"         
#> [146] "doct"       "death"      "nature"     "art"        "day"       
#> [151] "still"      "loue"       "shew"       "heart"      "macduffe"  
#> [156] "heare"      "ha"         "both"       "take"       "some"      
#> [161] "sey"        "way"        "men"        "she"        "owne"      
#> [166] "call"       "though"     "within"     "knock"      "put"       
#> [171] "strange"    "poore"      "worthy"     "euery"      "son"       
#> [176] "father"     "nothing"    "could"      "name"       "borne"     
#> [181] "heauen"     "thought"    "bloody"     "downe"      "goe"       
#> [186] "ayre"       "ere"        "malc"       "other"      "whose"     
#> [191] "euer"       "dead"       "without"    "against"    "deed"      
#> [196] "leaue"      "wee"        "murther"    "haile"      "god"       
#> [201] "made"       "neuer"      "dare"       "thus"       "about"     
#> [206] "thinke"     "none"       "hee"        "three"      "each"      
#> [211] "comes"      "malcolme"   "exit"       "much"       "cry"       
#> [216] "sword"      "new"        "noble"      "pray"       "keepe"     
#> [221] "beare"      "eye"        "into"       "honor"      "first"     
#> [226] "euen"       "bed"        "onely"      "hands"      "scotland"  
#> [231] "liues"      "liue"       "wood"       "gent"       "hang"      
#> [236] "once"       "very"       "go"         "away"       "finde"     
#> [241] "stand"      "face"       "double"     "whom"       "place"     
#> [246] "morrow"     "beene"      "peace"      "seruant"    "fight"     
#> [251] "else"       "hence"      "kings"      "hell"       "eyes"      
#> [256] "two"        "welcome"    "full"       "hold"       "sight"     
#> [261] "l"          "old"        "being"      "tell"       "words"     
#> [266] "seyward"    "thine"      "flye"       "thoughts"   "friends"   
#> [271] "murth"      "houre"      "woman"      "grace"      "duncan"    
#> [276] "mac"        "false"      "last"       "fleans"     "royall"    
#> [281] "bring"      "vnder"      "light"      "house"      "minde"     
#> [286] "lye"        "lesse"      "head"       "macduff"    "further"   
#> [291] "tyrant"     "nights"     "many"       "thunder"    "report"    
#> [296] "off"        "get"        "highnesse"  "rest"       "businesse" 
#> [301] "tongue"     "hope"       "feares"     "giuen"      "doctor"    
#> [306] "best"       "enough"     "witches"    "might"      "does"      
#> [311] "dunsinane"  "dayes"      "thing"      "true"       "rather"    
#> [316] "knowne"     "himselfe"   "re"         "lords"      "sorrow"    
#> [321] "children"   "any"        "fell"       "bell"       "drinke"    
#> [326] "almost"     "present"    "hast"       "set"        "sonne"     
#> [331] "gone"       "england"    "earth"      "truth"      "heard"     
#> [336] "better"     "knocking"   "desire"     "fled"       "oh"        
#> [341] "anon"       "knowes"     "meet"       "kill"       "sisters"   
#> [346] "seeme"      "sit"        "ban"        "trouble"    "power"     
#> [351] "fortune"    "mur"        "gracious"   "donalbaine" "while"     
#> [356] "comming"    "bid"        "goes"       "breath"     "throw"     
#> [361] "state"      "master"     "shake"      "daggers"    "since"     
#> [366] "after"      "attendants" "seene"      "dy"         "chamber"   
#> [371] "withall"    "english"    "lyes"       "issue"      "wisedome"  
#> [376] "seyton"     "shalt"      "doth"       "fall"       "deepe"     
#> [381] "little"     "rise"       "tyrants"    "mortall"    "thence"    
#> [386] "faith"      "forth"      "themselues" "world"      "gentle"    
#> [391] "thanes"     "cold"       "through"    "y"          "lay"       
#> [396] "natures"    "faire"      "whence"     "lost"       "colours"   
#> [401] "alarum"     "stay"       "makes"      "angus"      "vse"       
#> [406] "please"     "late"       "send"       "neere"      "left"      
#> [411] "word"       "helpe"      "powre"      "fate"       "hearke"    
#> [416] "messenger"  "another"    "round"      "command"    "honest"    
#> [421] "prima"      "attend"     "pale"       "high"       "spirits"   
#> [426] "eare"       "together"   "fill"       "strong"     "purpose"   
#> [431] "ring"       "returne"    "pleasure"   "darke"      "mother"    
#> [436] "hostesse"   "innocent"   "bad"        "toth"       "cauldron"  
#> [441] "country"    "answer"     "comfort"    "ouer"       "len"       
#> [446] "backe"      "seemes"     "terrible"   "point"      "ten"       
#> [451] "former"     "title"      "tertia"     "health"     "worst"     
#> [456] "husband"    "thither"    "cause"      "graue"      "bene"      
#> [461] "meanes"     "slaine"     "thrice"     "charme"     "farre"     
#> [466] "certaine"   "horses"     "women"      "sound"      "indeed"    
#> [471] "ment"       "soldiers"   "stands"     "water"      "foule"     
#> [476] "takes"      "reason"     "selues"     "secunda"    "said"      
#> [481] "meeting"    "thankes"    "home"       "crowne"     "harme"     
#> [486] "porter"     "faces"      "chance"     "actus"      "feast"     
#> [491] "braine"     "toward"     "free"       "amen"       "flourish"  
#> [496] "saw"        "em"         "fire"       "bold"       "horror"    
#> [501] "part"       "receiue"    "duties"     "safe"       "hither"    
#> [506] "sonnes"     "friend"     "strike"     "care"       "perfect"   
#> [511] "came"
```
