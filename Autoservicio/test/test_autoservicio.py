
import pytest

import brownie

PLATO = "Patatas"
TIEMPO_PAGO = 100
PRECIO = 5
DESCRIPCION = "Patatas"
PLATO2 = "Hambur"
DESCRIPCION2 = "Carne de ternera y lechuga"
PRECIO2 = 10

@pytest.fixture
def autoserv_contract(autoservicio, accounts):
    yield autoservicio.deploy(PLATO,DESCRIPCION,PRECIO,TIEMPO_PAGO,({'from': accounts[0]}))

def test_inicial(autoserv_contract,accounts):
    assert autoserv_contract.empresa() == accounts[0]
    assert autoserv_contract.tiempo_pago() == TIEMPO_PAGO
    assert autoserv_contract.carta(0) == (PLATO,DESCRIPCION,PRECIO)

def test_anadirquitar(autoserv_contract,accounts):
    autoserv_contract.anadir_plato(PLATO2,DESCRIPCION2,PRECIO2,{'from':accounts[0]})
    assert autoserv_contract.carta(1) == (PLATO2,DESCRIPCION2,PRECIO2)
    autoserv_contract.quitar_plato(1,{'from':accounts[0]})

def test_pedir(autoserv_contract,accounts):
    autoserv_contract.pedir(0,True,{'from':accounts[1]})
    autoserv_contract.pagarcuenta({'from': accounts[1],'value':5})
    assert autoserv_contract.cliente() == accounts[1]
    

def test_failed_transactions(autoserv_contract, accounts):
    autoserv_contract.pedir(0,True,{'from':accounts[1]})
    
    with brownie.reverts("Cliente"):
        autoserv_contract.pagarcuenta({'from': accounts[2],'value':5})
    
    with brownie.reverts("Precio"):
        autoserv_contract.pagarcuenta({'from': accounts[1],'value':3})
    
    
    with brownie.reverts("Empresa"):
        autoserv_contract.quitar_plato(0,{'from': accounts[1]})
    
    with brownie.reverts("Empresa"):
        autoserv_contract.anadir_plato(PLATO2,DESCRIPCION2,PRECIO2,{'from':accounts[3]})
        
    with brownie.reverts("Numero correcto"):
        autoserv_contract.quitar_plato(4,{'from':accounts[0]})
    
    with brownie.reverts("Empresa"):
        autoserv_contract.quitarcomanda({'from':accounts[1]})
    
    autoserv_contract.pagarcuenta({'from': accounts[1],'value':5})
    with brownie.reverts("Sin pagar"):
        autoserv_contract.quitarcomanda({'from':accounts[0]})
