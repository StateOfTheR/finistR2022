rm(list=ls())
library(tidyverse)
library(torch)
library(torchvision)


        #### Importation et mise en forme des donnees


dir = './'
x_train <- torchvision::mnist_dataset(
  dir, 
  download = TRUE, 
)
## On passe l'echelle de gris en [0,1]
xtrain = x_train$data/255
input_dim = dim(xtrain)[2]*dim(xtrain)[3]
xtrain <- torch_reshape(xtrain, c(nrow(xtrain), input_dim))
dim(xtrain)

## On recupere les labels
ytrain <- x_train$targets



        #### Generation d'un module de décodage



## Choix du nb de dim latentes
latent_dim = 2

## Création du decodeur à l'aide du decompresseur
decoder_gen <- nn_module(
  classname = "decoder", 
  ## Définition des couches
  initialize = function(dim.latent, dim.input) {
    self$l1 <- nn_linear(dim.latent, dim.input)
  }, 
  ## Définitions des calculs
  forward = function(input) {
    input %>% self$l1()
  }
)

## Verification
decoder <- decoder_gen(latent_dim,input_dim)
latent_vectors <- matrix(rnorm(10), nrow = 5, ncol = latent_dim) %>% torch_tensor() 
decoder(latent_vectors)

## Codage d'un module de NN de décodage plus sophistiqué
decompressor_gen <- function(dim.latent, dim.l1, dim.l2, dim.input) {
  nn_sequential(
    nn_linear(dim.latent, dim.l1),
    nn_relu(),
    nn_linear(dim.l1, dim.l2),
    nn_relu(),
    nn_linear(dim.l2, dim.input),
  )  
}

## Verification
decompressor <- decompressor_gen(latent_dim, 20, 100, input_dim)
decompressor(latent_vectors)

## Création du decodeur à l'aide du decompresseur
decoder_gen2 <- nn_module(
  classname = "decoder", 
  ## Définition des couches
  initialize = function(dim.latent, dim.l1, dim.l2, dim.input) {
    self$decompressor <- create_decompressor(dim.latent, dim.l1, dim.l2, dim.input)
  }, 
  ## Définitions des calculs
  forward = function(input) {
    input %>% self$decompressor()
  }
)

## Check
decoder <- decoder_gen2(latent_dim, 20, 100, input_dim)
decoder(latent_vectors)



        #### Generation d'un module d'encodage


## 1/ CREER UN MODULE DE COMPRESSION SYMETRIQUE DU MODULE DE DECOMPRESSION
#... et verifier qu'il marche !
compressor_gen <- function(dim.input, dim.l1, dim.l2) {
  nn_sequential(
    nn_linear(dim.input, dim.l1),
    nn_relu(),
    nn_linear(dim.l1, dim.l2),
    nn_relu()
    )  
}
compressor <- compressor_gen(input_dim, 100, 20)
compressor(xtrain[1,])


## 2/ CREER UN MODULE DE DECODAGE
# Qui encode d'abord globalement via le compresseur
# Qui a ensuite deux branches : 
# - une NN single layer pour la moyenne 
# - une NN single layer pour la variance 
#... et verifier qu'il marche

## Creation de l'encodeur
encoder_gen <- nn_module(
  classname = "encoder", 
  ## Définition des couches
  initialize = function(dim.input, dim.l1, dim.l2, dim.latent) {
    self$compressor <- compressor_gen(dim.input, dim.l1, dim.l2)
    self$mean <- nn_linear(dim.l2, dim.latent)
    self$log_var  <- nn_linear(dim.l2, dim.latent)
  }, 
  ## Définitions des calculs
  forward = function(input) {
    ## Calcul des répresentations compressées
    compressed <- input %>% self$compressor()
    ## Création des paramètres de moyenne et de variance
    mean <- compressed %>% self$mean()
    log_var <- compressed %>% self$log_var()
    ## L'encodeur renvoie mean et log_var
    list(mean = mean, log_var = log_var)
  }
)
encoder <- encoder_gen(input_dim,100,20, latent_dim)
encoder(xtrain[1, ])
