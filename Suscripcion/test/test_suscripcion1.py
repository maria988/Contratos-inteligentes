
import pytest

import brownie
import time

CUOTA = 10
PERIODO = 5


@pytest.fixture
def suscripcion1_contract(suscripcion1, accounts):
    yield suscripcion1.deploy(CUOTA,PERIODO,{'from': accounts[0]})

def test_inicial(suscripcion1_contract,accounts):
    assert suscripcion1_contract.empresa() == accounts[0]
    assert suscripcion1_contract.cuota() == CUOTA
    assert suscripcion1_contract.periodo() == PERIODO

def test_uso(suscripcion1_contract,accounts):
    tx1 = suscripcion1_contract.darse_de_alta({'from': accounts[2],'value':30})
    tx2 = suscripcion1_contract.darse_de_alta({'from':accounts[1],'value':10})
    suscripcion1_contract.enviar(accounts[1],{'from':accounts[0]})
    suscripcion1_contract.enviar(accounts[2],{'from':accounts[0]})
    tx3 = suscripcion1_contract.recibido({'from':accounts[2]})
    
    time.sleep(5)
    tx4 = suscripcion1_contract.no_recibido({'from':accounts[1]})
    tx5 = suscripcion1_contract.recibido({'from':accounts[1]})
    suscripcion1_contract.comprobar({'from':accounts[0]})
    
    suscripcion1_contract.darse_de_baja({'from':accounts[1]})
    suscripcion1_contract.pagar({'from':accounts[2],'value':0})
    suscripcion1_contract.enviar(accounts[2],{'from':accounts[0]})
    suscripcion1_contract.recibido({'from':accounts[2]})
    time.sleep(5)
    suscripcion1_contract.comprobar({'from':accounts[0]})
    
    assert len(tx1.events)==1
    assert tx1.events[0]['emisor'] == accounts[2]
    assert tx1.events[0]['valor'] == CUOTA
    assert len(tx2.events)==1
    assert tx2.events[0]['emisor'] == accounts[1]
    assert tx2.events[0]['valor'] == CUOTA
    assert len(tx3.events)==1
    assert tx3.events[0]['receptor'] == accounts[0]
    assert tx3.events[0]['emisor'] == accounts[2]
    assert tx3.events[0]['texto'] == "Recibido"
    assert len(tx4.events)==1
    assert tx4.events[0]['receptor'] == accounts[0]
    assert tx4.events[0]['emisor'] == accounts[1]
    assert tx4.events[0]['texto'] == "No recibido"
    assert len(tx5.events)==1
    assert tx5.events[0]['receptor'] == accounts[0]
    assert tx5.events[0]['emisor'] == accounts[1]
    assert tx5.events[0]['texto'] == "Recibido"
    
def test_failed_transactions(suscripcion1_contract, accounts):
    suscripcion1_contract.darse_de_alta({'from':accounts[1],'value':10})
    with brownie.reverts("No ha pagado"):
        suscripcion1_contract.pagar({'from':accounts[1],'value':10})
        
    with brownie.reverts("Enviado"):
        suscripcion1_contract.no_recibido({'from':accounts[1]})
        
    with brownie.reverts("Enviado"):
        suscripcion1_contract.recibido({'from':accounts[1]})
        
    suscripcion1_contract.enviar(accounts[1],{'from':accounts[0]})
    
    with brownie.reverts("Tiempo superado"):
        suscripcion1_contract.no_recibido({'from':accounts[1]})
    
    suscripcion1_contract.recibido({'from':accounts[1]})
    with brownie.reverts("Supera el periodo"):
        suscripcion1_contract.comprobar({'from':accounts[0]})
    with brownie.reverts("No enviado"):
        suscripcion1_contract.enviar(accounts[1],{'from':accounts[0]})
        
    with brownie.reverts("No registrado"):
        suscripcion1_contract.darse_de_alta({'from':accounts[1],'value':20})
        
    with brownie.reverts("Valor suficiente"):
        suscripcion1_contract.darse_de_alta({'from':accounts[2],'value':5})
        
    with brownie.reverts("Registrado"):
        suscripcion1_contract.darse_de_baja({'from':accounts[2]})
        
    with brownie.reverts("Registrado"):
        suscripcion1_contract.pagar({'from':accounts[2],'value':20})
    
    with brownie.reverts("Registrado"):
        suscripcion1_contract.no_recibido({'from':accounts[2]})
        
    with brownie.reverts("Registrado"):
        suscripcion1_contract.recibido({'from':accounts[2]})
        
    with brownie.reverts("Valor suficiente"):
        suscripcion1_contract.pagar({'from':accounts[1],'value':5})
        
    with brownie.reverts("Empresa"):
        suscripcion1_contract.enviar(accounts[2],{'from':accounts[1]})
        
    with brownie.reverts("Registrado"):
        suscripcion1_contract.enviar(accounts[3],{'from':accounts[0]})
    
    suscripcion1_contract.darse_de_alta({'from':accounts[2],'value':10})
    suscripcion1_contract.enviar(accounts[2],{'from':accounts[0]})
    suscripcion1_contract.recibido({'from':accounts[2]})  
    time.sleep(5)
    with brownie.reverts("Empresa"):
        suscripcion1_contract.comprobar({'from':accounts[1]})
        
    suscripcion1_contract.comprobar({'from':accounts[0]})
    
    with brownie.reverts("Pagado"):
        suscripcion1_contract.enviar(accounts[1],{'from':accounts[0]})
        
    suscripcion1_contract.pagar({'from':accounts[1],'value':20})
    suscripcion1_contract.enviar(accounts[1],{'from':accounts[0]})
    suscripcion1_contract.pagar({'from':accounts[2],'value':20})
    suscripcion1_contract.enviar(accounts[2],{'from':accounts[0]})
    suscripcion1_contract.recibido({'from':accounts[1]})
    
    time.sleep(5)
    suscripcion1_contract.no_recibido({'from':accounts[2]})
    suscripcion1_contract.comprobar({'from':accounts[0]})
    with brownie.reverts("No falla"):
        suscripcion1_contract.comprobar({'from':accounts[0]})
        
