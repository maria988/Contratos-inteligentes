
import pytest

import brownie
import time
PRECIO = 50
TIEMPO_ENVIO = 2
DEVOLVER = 25


@pytest.fixture
def envio2_contract(Envioatiempo2, accounts):
    yield Envioatiempo2.deploy(PRECIO,DEVOLVER,TIEMPO_ENVIO,{'from': accounts[0]})

def test_inicial(envio2_contract,accounts):
    assert envio2_contract.empresa()==accounts[0]
    assert envio2_contract.precio() == PRECIO
    assert envio2_contract.devolver() == DEVOLVER
    assert envio2_contract.tiempo_envio() == TIEMPO_ENVIO
    
    
def test_events1(envio2_contract,accounts):
    tx1 = envio2_contract.comprar({'from':accounts[1],'value':PRECIO})
    
    assert (len(tx1.events) == 1)
    assert tx1.events[0]['comprador'] == accounts[1]
    assert tx1.events[0]['vendedor'] == accounts[0]
    assert tx1.events[0]['valor'] == PRECIO
    time.sleep(3)
    tx2 = envio2_contract.frecibido({'from':accounts[1]})
    
    assert(len(tx2.events)==1)
    assert tx2.events[0]['emisor'] == accounts[0]
    assert tx2.events[0]['receptor'] == accounts[1]
    assert tx2.events[0]['devolver'] == DEVOLVER
    
def test_events2(envio2_contract,accounts):
    tx1 = envio2_contract.comprar({'from':accounts[1],'value':PRECIO})
    
    assert (len(tx1.events) == 1)
    assert tx1.events[0]['comprador'] == accounts[1]
    assert tx1.events[0]['vendedor'] == accounts[0]
    assert tx1.events[0]['valor'] == PRECIO
    
    tx2 = envio2_contract.frecibido({'from':accounts[1]})
    
    assert(len(tx2.events)==1)
    assert tx2.events[0]['emisor'] == accounts[0]
    assert tx2.events[0]['receptor'] == accounts[1]
    assert tx2.events[0]['devolver'] == 0  
    
def test_failed_transactions(envio2_contract, accounts):
    
    with brownie.reverts("Precio exacto"):
        envio2_contract.comprar({'from': accounts[1],'value':10})
    
    envio2_contract.comprar({'from':accounts[1],'value': PRECIO})
    
    with brownie.reverts("No se ha comprado"):
        envio2_contract.comprar({'from': accounts[1],'value':50})
    
    
    with brownie.reverts("Comprador"):
        envio2_contract.frecibido({'from': accounts[2]})
    
    envio2_contract.frecibido({'from':accounts[1]})
    
    
    
