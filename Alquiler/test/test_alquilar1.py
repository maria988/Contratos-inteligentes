
import pytest

import brownie
import time
INITIAL_VALUE = 100
MENSUALIDAD = 200
TIEMPO = 3
TIEMPO_CONTRATO = 10

@pytest.fixture
def alquiler1_contract(Alquiler1, accounts):
    yield Alquiler1.deploy(MENSUALIDAD,TIEMPO,TIEMPO_CONTRATO,{'from': accounts[0],'value':INITIAL_VALUE})

def test_initial(alquiler1_contract,accounts):
    assert alquiler1_contract.fianza() == INITIAL_VALUE
    assert alquiler1_contract.arrendador() == accounts[0]
    assert alquiler1_contract.mensualidad() == MENSUALIDAD
    assert alquiler1_contract.tiempo() == TIEMPO
    assert alquiler1_contract.tiempo_contrato() == TIEMPO_CONTRATO

    
def test_events(alquiler1_contract, accounts):
    tx1 = alquiler1_contract.alquilar({'from': accounts[1],'value':300})
    alquiler1_contract.pagar({'from':accounts[1],'value': 200})
    time.sleep(5)
    tx2 = alquiler1_contract.cambio({'from':accounts[0]})
    assert len(tx1.events) == 1
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor']== accounts[0]
    assert tx1.events[0]['valor']== 200
    
    assert len(tx2.events) == 1
    assert tx2.events[0]['emisor'] == accounts[1]
    assert tx2.events[0]['receptor']== accounts[0]
    assert tx2.events[0]['valor']== 200
    
    
def test_failed_transactions(alquiler1_contract, accounts):
    
    with brownie.reverts("Valor exacto"):
        alquiler1_contract.alquilar({'from':accounts[2],'value':200})
    
    with brownie.reverts("Alquilada"):
        alquiler1_contract.cambio({'from':accounts[2]})
    
    with brownie.reverts("Alquilada"):
        alquiler1_contract.pagar({'from':accounts[2],'value':200})
        
    alquiler1_contract.alquilar({'from':accounts[2],'value':300})
    
    with brownie.reverts("No esta alquilada"):
        alquiler1_contract.alquilar({'from':accounts[3],'value':200})
        
    with brownie.reverts("Plazo cumplido"):
        alquiler1_contract.cambio({'from':accounts[2]})
    
    with brownie.reverts("Mensualidad"):
        alquiler1_contract.pagar({'from':accounts[2],'value':100})
        
    time.sleep(4)
    with brownie.reverts("Arrendador o arrendatario"):
        alquiler1_contract.cambio({'from':accounts[1]})
        
    with brownie.reverts("Arrendatario"):
        alquiler1_contract.pagar({'from':accounts[1],'value':200})
    
    with brownie.reverts("Arrendador"):
        alquiler1_contract.eliminarcontrato({'from':accounts[1]})
    
    time.sleep(5)
    with brownie.reverts("Dentro del plazo"):
        alquiler1_contract.pagar({'from':accounts[2],'value':200})
        
    with brownie.reverts("Dentro del tiempo del contrato"):
        alquiler1_contract.eliminarcontrato({'from':accounts[0]})
