library(XML)
library(rjson)

## Datos de la registraduría

url <- "http://www.registraduria.gov.co/?page=candidatos_2014"
tablas <- readHTMLTable(url)
candidatos2014.df <- tablas[[2]]
names(candidatos2014.df) <- c("número", "departamento", "corporación", "partido", "nombre")
columnas.texto = c(2,3,4,5)
for(i in columnas.texto){
  levels(candidatos2014.df[,i]) <- tolower(levels(candidatos2014.df[,i])) 
}
levels(candidatos2014.df$corporación) <- c("cámara afro", "cámara", "cámara indígena", "parlamento andino", "senado", "senado indígena")

write.csv(candidatos2014.df, file="registraduria.csv", row.names=F)

## Datos de congreso visible.

url.cv <- "http://congresovisible.org/api/apis/candidatos/"
cong.vis.jsones <- vector(mode = "list", length = 114)
for(i in 1:114){
cong.vis.jsones[[i]] <- fromJSON(file=paste(url.cv, "?page=", i, sep=''), method='C') 
print(paste("Descargado ", i, sep=''))
}
# 114 páginas.

nombres.cong.vis <- c("nombres", "apellidos", "numero.lista", "corporacion", "partido", "genero", "nacimiento", "tiempo.congreso", "La eutanasia", "El sexo antes del matrimonio", "El matrimonio homosexual", "El divorcio", "El consumo de marihuana", "El aborto", "Estatuto de la Ciudadanía Juvenil", "Justicia Penal Militar, Fuero Militar", "Reforma a la Justicia Ejecutivo", "Implementación del TLC con Estados Unidos, Ley Lleras 2.0", "Ley estatutaria de reforma a la salud")
cong.vis.df <- data.frame(matrix(vector(), 4000, length(nombres.cong.vis), dimnames=list(c(), nombres.cong.vis)))

contador = 0
for(k in 1:114){
cv <- cong.vis.jsones[[k]]
t <- cv$results
for(i in 1:length(t)){
  contador = contador + 1
  print(contador)
  x <- t[[i]]
  r <- c(x$first_name, 
         x$last_name, 
         x$list_number,
         x$candidate_for, 
         x$party$name, 
         x$gender, 
         x$biography$born_date, 
         x$trajectory$years_in_congress)
  r<- c(r, rep(NA,11)) 
  cong.vis.df[contador,] <- r
  if(length(x$topics_positions) > 0){
  for(j in 1:length(x$topics_positions)){
    varname <- gsub(" ", ".", x$topics_positions[[j]]$name)
    cong.vis.df[contador,varname] <- x$topics_positions[[j]]$posicion
  }
  if(length(x$project_votes)>0){
    for(j in 1:length(x$project_votes)){
      varname <- gsub(" ", ".", x$project_votes[[j]]$name)
      varname <- gsub(",", ".", varname)
      cong.vis.df[contador,varname] <- x$project_votes[[j]]$posicion
    }
  }
  }
}
}

# Cortar

cong.vis.df <- cong.vis.df[1:2277,]

fact.col <- c(3:6, 9:19) 
cong.vis.df[fact.col] <- lapply(cong.vis.df[fact.col], as.factor)
fact.num <- 7:8
cong.vis.df[fact.num] <- lapply(cong.vis.df[fact.num], as.numeric)

write.csv(cong.vis.df, file="congreso.visible.csv", row.names=F)
