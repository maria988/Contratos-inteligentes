
import pytest

import brownie
import time
INITIAL_VALUE = 100
MENS = 200
TIEMPO = 3
TIEMPO_CONTRATO = 10
CLAVE = 234

@pytest.fixture
def alquiler2_contract(Alquiler2, accounts):
    yield Alquiler2.deploy(MENS,TIEMPO,TIEMPO_CONTRATO,CLAVE,{'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(alquiler2_contract,accounts):
    assert alquiler2_contract.fianza() == INITIAL_VALUE
    assert alquiler2_contract.arrendador() == accounts[0]
    assert alquiler2_contract.mensualidad() == MENS
    assert alquiler2_contract.tiempo()== TIEMPO
    assert alquiler2_contract.tiempo_contrato() == TIEMPO_CONTRATO
    
def test_events(alquiler2_contract, accounts):
    tx1 =alquiler2_contract.alquilar({'from': accounts[1],'value':300})
    alquiler2_contract.pagar({'from':accounts[1],'value': 200})
    alquiler2_contract.darllave(123,{'from':accounts[0]})
    time.sleep(5)
    tx2 = alquiler2_contract.cambio({'from':accounts[0]})
    assert len(tx1.events) == 2
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor']== accounts[0]
    assert tx1.events[0]['valor']== 200
    assert tx1.events[1]['receptor'] == accounts[1]
    assert tx1.events[1]['emisor'] == accounts[0]
    assert tx1.events[1]['clave_'] == CLAVE
    
    assert len(tx2.events) == 2
    assert tx2.events[0]['emisor'] == accounts[1]
    assert tx2.events[0]['receptor']== accounts[0]
    assert tx2.events[0]['valor']== 200
    assert tx2.events[1]['receptor'] == accounts[1]
    assert tx2.events[1]['emisor'] == accounts[0]
    assert tx2.events[1]['clave_'] == 123
    
    
def test_failed_transactions(alquiler2_contract, accounts):
    
    with brownie.reverts("Valor exacto"):
        alquiler2_contract.alquilar({'from':accounts[2],'value':200})
    
    with brownie.reverts("Alquilada"):
        alquiler2_contract.cambio({'from':accounts[2]})
    
    with brownie.reverts("Alquilada"):
        alquiler2_contract.pagar({'from':accounts[2],'value':200})
        
    with brownie.reverts("Alquilada"):
        alquiler2_contract.darllave(123,{'from':accounts[2]})
        
    alquiler2_contract.alquilar({'from':accounts[2],'value':300})
    
    with brownie.reverts("No esta alquilada"):
        alquiler2_contract.alquilar({'from':accounts[3],'value':200})
        
    with brownie.reverts("Plazo cumplido"):
        alquiler2_contract.cambio({'from':accounts[2]})
    
    with brownie.reverts("Mensualidad"):
        alquiler2_contract.pagar({'from':accounts[2],'value':100})
        
    with brownie.reverts("Arrendador"):
        alquiler2_contract.darllave(123,{'from':accounts[2]})    
        
    
    time.sleep(4)
    with brownie.reverts("Dentro de plazo"):
        alquiler2_contract.darllave(123,{'from':accounts[0]})
    with brownie.reverts("Arrendador o arrendatario"):
        alquiler2_contract.cambio({'from':accounts[1]})
        
    with brownie.reverts("Arrendatario"):
        alquiler2_contract.pagar({'from':accounts[1],'value':200})
    
    with brownie.reverts("Arrendador"):
        alquiler2_contract.eliminarcontrato({'from':accounts[1]})
    
    time.sleep(5)
    with brownie.reverts("Dentro del plazo"):
        alquiler2_contract.pagar({'from':accounts[2],'value':200})
        
    with brownie.reverts("Dentro del tiempo del contrato"):
        alquiler2_contract.eliminarcontrato({'from':accounts[0]})
