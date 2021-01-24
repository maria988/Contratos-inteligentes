
import pytest

import brownie
import time
PRECIO = 50
TIEMPO_ENVIO = 2
INITIAL_VALUE = 25


@pytest.fixture
def envio1_contract(envioatiempo1, accounts):
    yield envioatiempo1.deploy(PRECIO,TIEMPO_ENVIO,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(envio1_contract,accounts):
    assert envio1_contract.empresa()==accounts[0]
    assert envio1_contract.precio() == PRECIO
    assert envio1_contract.devolver() == INITIAL_VALUE
    assert envio1_contract.tiempo_envio() == TIEMPO_ENVIO
    
    
def test_events1(envio1_contract,accounts):
    tx1 = envio1_contract.comprar({'from':accounts[1],'value':PRECIO})
    
    assert (len(tx1.events) == 1)
    assert tx1.events[0]['comprador'] == accounts[1]
    assert tx1.events[0]['vendedor'] == accounts[0]
    assert tx1.events[0]['valor'] == PRECIO
    time.sleep(3)
    tx2 = envio1_contract.frecibido({'from':accounts[1]})
    
    assert(len(tx2.events)==1)
    assert tx2.events[0]['emisor'] == accounts[0]
    assert tx2.events[0]['receptor'] == accounts[1]
    assert tx2.events[0]['devolver'] == INITIAL_VALUE
    
def test_events2(envio1_contract,accounts):
    tx1 = envio1_contract.comprar({'from':accounts[1],'value':PRECIO})
    
    assert (len(tx1.events) == 1)
    assert tx1.events[0]['comprador'] == accounts[1]
    assert tx1.events[0]['vendedor'] == accounts[0]
    assert tx1.events[0]['valor'] == PRECIO
    
    tx2 = envio1_contract.frecibido({'from':accounts[1]})
    
    assert(len(tx2.events)==1)
    assert tx2.events[0]['emisor'] == accounts[0]
    assert tx2.events[0]['receptor'] == accounts[1]
    assert tx2.events[0]['devolver'] == 0  
    
def test_failed_transactions(envio1_contract, accounts):
    
    with brownie.reverts("Precio exacto"):
        envio1_contract.comprar({'from': accounts[1],'value':10})
    
    envio1_contract.comprar({'from':accounts[1],'value': PRECIO})
    
    with brownie.reverts("No se ha comprado"):
        envio1_contract.comprar({'from': accounts[1],'value':50})
    
    
    with brownie.reverts("Comprador"):
        envio1_contract.frecibido({'from': accounts[2]})
    
    envio1_contract.frecibido({'from':accounts[1]})
    
    
    
