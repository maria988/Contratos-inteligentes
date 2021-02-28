import pytest

import brownie

PUNTOS = 20
LITROSG = 30
APUNTOS = 1

@pytest.fixture
def puntos_contract(puntos, accounts):
    yield puntos.deploy(PUNTOS,LITROSG,APUNTOS,{'from': accounts[0]})

def test_inicial(puntos_contract,accounts):
    assert puntos_contract.empresa() == accounts[0]
    assert puntos_contract.puntos() == PUNTOS
    assert puntos_contract.litrosgratis() == LITROSG
    assert puntos_contract.apuntos() == APUNTOS

def test_uso(puntos_contract,accounts):
    puntos_contract.nuevocliente(accounts[1],{'from': accounts[1]})
    puntos_contract.acumularpuntos(20,accounts[1],{'from':accounts[0]})
    assert puntos_contract.list_clientes(accounts[1]) == (True,PUNTOS,0)
    puntos_contract.usarpuntos(accounts[1],{'from':accounts[0]})
    assert puntos_contract.list_clientes(accounts[1])== (True,0,LITROSG)
    puntos_contract.usarlitros(accounts[1],LITROSG,{'from':accounts[0]})
    assert puntos_contract.list_clientes(accounts[1])== (True,0,0)
    puntos_contract.dejardesercliente(accounts[1])
    assert puntos_contract.list_clientes(accounts[1])== (False,0,0)
    
    
def test_failed_transactions(puntos_contract, accounts):
    
    with brownie.reverts("Es cliente"):
        puntos_contract.acumularpuntos(10,accounts[1])
        
    with brownie.reverts("Es cliente"):
        puntos_contract.usarpuntos(accounts[1])
        
    with brownie.reverts("Es cliente"):
        puntos_contract.usarlitros(accounts[1],10)
    
    with brownie.reverts("Es cliente"):
        puntos_contract.dejardesercliente(accounts[1])
        
    puntos_contract.nuevocliente(accounts[1])
    
    with brownie.reverts("No es cliente"):
        puntos_contract.nuevocliente(accounts[1])
        
    with brownie.reverts("Positivo"):
        puntos_contract.acumularpuntos(0,accounts[1])
        
    with brownie.reverts("Puntos suficientes o litros gratis"):
        puntos_contract.usarpuntos(accounts[1])
    
    with brownie.reverts("Suficientes litros"):
        puntos_contract.usarlitros(accounts[1],10)
