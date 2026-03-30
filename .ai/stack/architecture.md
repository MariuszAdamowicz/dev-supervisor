# Architektura

## App
Zawiera widoki SwiftUI, view modele i elementy spinające cykl życia aplikacji.

## Core
Zawiera logikę domenową i moduły wielokrotnego użytku.

## Services
Zawiera integracje z zewnętrznymi API.

## Reguła
Jeśli logika jest używana przez więcej niż jedną funkcję, nie powinna pozostawać w implementacji specyficznej dla jednej funkcji.
