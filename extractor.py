# Un script para descargar seguidores de candidatos al congreso en Twitter 
# La lista de candidatos proviene de la base de datos de La Silla Vacía
# Bajar toda la información tomó mucho tiempo porque creo que fui demasiado chambón 
# controlando los requests para no excederme en el límite del API. 

import tweepy
import time
from __future__ import division
import json

consumer_key = ''
consumer_secret = ''
access_token = ''
access_token_secret = ''
 

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)

def followerids(user):
    output = []
    i = 0
    for page in tweepy.Cursor(api.followers_ids, screen_name=user).pages():
        i += 1
        print "Congresista: " + user + " (Pagina "+ str(i) + ")"
        output.extend(page)
        print "Pausa de 60 segundos"
        time.sleep(60)   
    return output

def datosCongresista(user):
    output = {}
    congresista = api.get_user(user)
    output["id"] = congresista.id
    output["nacimiento"] = congresista.created_at
    output["numseguidores"] = congresista.followers_count
    print "Número de seguidores: " + str(output["numseguidores"])
    print "Pausa de 10 segundos"
    time.sleep(10)
    output["seguidores"] = followerids(user)
    return output

datos = {}

def cuentasCongresistas(lista):
    count = 0
    for user in lista:
        count += 1
        print "Congresista número " + str(count) + ": " + user
        datos[user] = datosCongresista(user)

archivocuentas = "cuentas"
cuentascandidatos = []
for line in open(archivocuentas):
    cuentascandidatos = cuentascandidatos + [line[:-1]]

cuentasCongresistas(cuentascandidatos)

def date_handler(obj):
    return obj.isoformat() if hasattr(obj, 'isoformat') else obj

archivo = "minadecandidatos.json"

json.dump(datos, open(archivo,'w'), default=date_handler)

# datos = json.load(open(archivo))