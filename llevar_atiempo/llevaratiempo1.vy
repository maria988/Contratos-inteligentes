#Alquiler de transporte
empresa : public(address)
transporte: public(address)
t_estimado: public(uint256)
penalizacion_sueldo: public(uint256)
sueldo: public(uint256)

@payable
@external
def __init__(_transporte: address, _tiempo_estimado: uint256,_pens: uint256):
    self.empresa = msg.sender
    self.transporte = _transporte
    self.t_estimado = _tiempo_estimado
    self.penalizacion_sueldo = _pens
    self.sueldo = msg.value

@external
def fin():
    assert msg.sender == self.empresa
    if block.timestamp <= self.t_estimado:
        send(self.transporte,self.sueldo)
    else:
        t_espera: uint256 = block.timestamp
        penalizacion : uint256 = (t_espera - self.t_estimado) * self.penalizacion_sueldo
        if self.sueldo >  penalizacion:
            send(self.transporte,self.sueldo - penalizacion)
    selfdestruct(self.empresa)
