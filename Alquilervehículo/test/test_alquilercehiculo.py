
import pytest

import brownie

PRECIO_UDT = 2
PRECIO_INICIO = 2

@pytest.fixture
def alqvehiculo_contract(Alquilervehiculo, accounts):
    yield Alquilervehiculo.deploy(PRECIO_UDT,PRECIO_INICIO,{'from': accounts[0]})

def test_inicial(alqvehiculo_contract,accounts):
    assert alqvehiculo_contract.precio_udt() == PRECIO_UDT
    assert alqvehiculo_contract.empresa() == accounts[0]
    assert alqvehiculo_contract.precio_inicio() == PRECIO_INICIO
    
def test_events(alqvehiculo_contract, accounts):
    alqvehiculo_contract.alquilar({'from': accounts[1],'value':30})
    alqvehiculo_contract.dejar({'from': accounts[1]})
    
    assert not alqvehiculo_contract.usado()
    


def test_failed_transactions(alqvehiculo_contract, accounts):
    # Try to set the storage to a negative amount
    
    
    with brownie.reverts("Suficiente"):
        alqvehiculo_contract.alquilar({'from': accounts[2],'value':0})
    
    alqvehiculo_contract.alquilar({'from':accounts[2],'value':50})
    with brownie.reverts("Empresa"):
        alqvehiculo_contract.fin_viaje({'from': accounts[2]})
    
    with brownie.reverts("Persona"):
        alqvehiculo_contract.dejar({'from': accounts[0]})
        
    alqvehiculo_contract.dejar({'from':accounts[2]})
    
    with brownie.reverts("En uso"):
        alqvehiculo_contract.fin_viaje({'from': accounts[0]})
        
    with brownie.reverts("En uso"):
        alqvehiculo_contract.dejar({'from': accounts[1]})
        
