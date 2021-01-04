
import pytest

import brownie
import time
TIEMPO_ESTIMADO = 3
PENALIZACION = 100
PRECIO = 200

@pytest.fixture
def llevartiempo_contract(llevaratiempo1, accounts):
    yield llevaratiempo1.deploy(accounts[1],TIEMPO_ESTIMADO,PENALIZACION,{'from': accounts[0],'value':PRECIO})

def test_inicial(llevartiempo_contract,accounts):
    assert llevartiempo_contract.empresa() == accounts[0]
    assert llevartiempo_contract.transporte() == accounts[1]
    assert llevartiempo_contract.t_estimado() == TIEMPO_ESTIMADO
    assert llevartiempo_contract.penalizacion_sueldo() == PENALIZACION
    assert llevartiempo_contract.sueldo() == PRECIO
    
    
def test_events1(llevartiempo_contract,accounts):
    llevartiempo_contract.inicio({'from':accounts[1]})
    tx1 = llevartiempo_contract.fin({'from':accounts[0]})
    assert len(tx1.events) == 1
    assert tx1.events[0]['emisor']==accounts[0]
    assert tx1.events[0]['receptor']==accounts[1]
    assert tx1.events[0]['valor'] == PRECIO

def test_events2(llevartiempo_contract, accounts):
    llevartiempo_contract.inicio({'from':accounts[1]})
    time.sleep(5)
    tx2 = llevartiempo_contract.fin({'from':accounts[0]})
    assert len(tx2.events) == 1
    assert tx2.events[0]['emisor']==accounts[0]
    assert tx2.events[0]['receptor']==accounts[1]
    assert tx2.events[0]['valor'] == PRECIO - PENALIZACION
    
def test_failed_transactions(llevartiempo_contract, accounts):
    
    
    with brownie.reverts("Iniciado"):
        llevartiempo_contract.fin({'from':accounts[1]})
    
    with brownie.reverts("Transporte"):
        llevartiempo_contract.inicio({'from':accounts[0]})
    
    llevartiempo_contract.inicio({'from':accounts[1]})
    
    with brownie.reverts("No iniciado"):
        llevartiempo_contract.inicio({'from':accounts[1]})
    
    with brownie.reverts("Empresa"):
        llevartiempo_contract.fin({'from':accounts[1]})
