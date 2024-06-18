#!/bin/bash

PREFIX="/kobe/output/federated-sparql.ttl"

touch $PREFIX

echo "PREFIX rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd:    <http://www.w3.org/2001/XMLSchema#>
PREFIX fd:     <http://www.example.org/se/liu/ida/hefquin/fd#>
PREFIX ex:     <http://example.org/>

" >> $PREFIX

cd /kobe/input

cat *.nt >> /kobe/output/federated-sparql.ttl
