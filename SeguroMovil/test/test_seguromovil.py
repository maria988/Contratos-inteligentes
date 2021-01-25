import pytest

import brownie
import time

DURACION = 4
PRECIO1 = 10
PRECIO2 = 40
DESCRIPCION1 = "Roturas de pantalla"
DESCRIPCION2 = "Roturas de pantalla y robos"
PARTES1 = 1
PARTES2 = 3
IMEI = "1234567890ABCDE"

@pytest.fixture
def seguromovil_contract(seguromovil, accounts):
    yield seguromovil.deploy(DURACION,PRECIO1,PRECIO2,DESCRIPCION1,DESCRIPCION2,PARTES1,PARTES2,{'from': accounts[0]})

def test_inicial(seguromovil_contract,accounts):
    assert seguromovil_contract.aseguradora() == accounts[0]
    assert seguromovil_contract.duracion() == DURACION
    assert seguromovil_contract.tipo(1) == (PRECIO1,DESCRIPCION1,PARTES1)
    assert seguromovil_contract.tipo(2) == (PRECIO2,DESCRIPCION2,PARTES2)

def test_event(seguromovil_contract,accounts):
    
    assert seguromovil_contract.consultar_descripcion(1) == DESCRIPCION1
    assert seguromovil_contract.consultar_precio(2) == PRECIO2
    seguromovil_contract.contratar(IMEI,{'from':accounts[1],'value':PRECIO1})
    tx1 = seguromovil_contract.dar_parte("Se ha mojado",IMEI,{'from':accounts[1]})
    tx2 = seguromovil_contract.remunerar(False,"No incluido en el contrato",{'from':accounts[0],'value':0})
    
    tx3 = seguromovil_contract.dar_parte("Pantalla rota",IMEI,{'from':accounts[1]})
    tx4 =  seguromovil_contract.remunerar(True,"Aceptado",{'from':accounts[0],'value':100})
    
    time.sleep(5)
    seguromovil_contract.fin({'from':accounts[0]})
    
    assert len(tx1.events) == 1
    assert tx1.events[0]['cliente'] == accounts[1]
    assert tx1.events[0]['aseguradora'] == accounts[0]
    assert tx1.events[0]['descripcion'] == "Se ha mojado"
    assert tx1.events[0]['tipo_contrato'] == 1
    
    assert len(tx2.events) == 1
    assert tx2.events[0]['cliente'] == accounts[1]
    assert tx2.events[0]['valor'] == 0
    assert tx2.events[0]['causas'] == "No incluido en el contrato"
    
    assert len(tx3.events) == 1
    assert tx3.events[0]['cliente'] == accounts[1]
    assert tx3.events[0]['aseguradora'] == accounts[0]
    assert tx3.events[0]['descripcion'] == "Pantalla rota"
    assert tx3.events[0]['tipo_contrato'] == 1
    
    assert len(tx4.events) == 1
    assert tx4.events[0]['cliente'] == accounts[1]
    assert tx4.events[0]['valor'] == 100
    assert tx4.events[0]['causas'] == "Aceptado"
    
    
def test_failed_transactions(seguromovil_contract, accounts):
    
    with brownie.reverts("Precio exacto"):
        seguromovil_contract.contratar(IMEI,{'from':accounts[3],'value': 2})
     
    with brownie.reverts("Contratado"):
        seguromovil_contract.dar_parte("Se ha mojado",IMEI,{'from':accounts[3]})
    
    seguromovil_contract.contratar(IMEI,{'from':accounts[1],'value': PRECIO1})
    
    with brownie.reverts("No contratado"):
        seguromovil_contract.contratar(IMEI,{'from':accounts[3],'value': 2})
    
    with brownie.reverts("Cliente"):
        seguromovil_contract.dar_parte("Se ha mojado",IMEI,{'from':accounts[3]})
    
    with brownie.reverts("Imei correcto"):
        seguromovil_contract.dar_parte("Se ha mojado","112344",{'from':accounts[1]})
    
    with brownie.reverts("Se ha expedido un parte"):
        seguromovil_contract.remunerar(False,"No incluido en el contrato",{'from':accounts[0],'value':0})
   
    seguromovil_contract.dar_parte("Pantalla rota",IMEI,{'from':accounts[1]})
    
    with brownie.reverts("Aseguradora"):
        seguromovil_contract.remunerar(False,"No incluido en el contrato",{'from':accounts[2],'value':0})
    
    seguromovil_contract.remunerar(True,"Aceptado",{'from':accounts[0],'value':100})
    
    with brownie.reverts("Hay partes"):
        seguromovil_contract.dar_parte("Se ha mojado",IMEI,{'from':accounts[1]})
    
    with brownie.reverts("Aseguradora"):
        seguromovil_contract.fin({'from':accounts[3]})
    
    with brownie.reverts("Despues del tope"):
        seguromovil_contract.fin({'from':accounts[0]})
        
    time.sleep(5)
    
    with brownie.reverts("Dentro de tope"):
        seguromovil_contract.dar_parte("Se ha mojado",IMEI,{'from':accounts[1]})
