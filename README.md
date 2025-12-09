# Inventory Management Database System 📦

A robust relational database solution designed for **SQL Server (T-SQL)** to manage warehouse inventory, supplier relationships, sales/procurement transactions, and price history tracking.

![SQL Server](https://img.shields.io/badge/Database-SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)

## 📋 Project Overview

This project simulates a backend database for an ERP (Enterprise Resource Planning) module. It handles:
* **Stock Management:** Tracking items across multiple storage locations.
* **Supply Chain:** Managing relationships between articles and suppliers.
* **Transaction Logging:** Auditing all IN/OUT movements (Sales & Procurement).
* **Price History:** Maintaining historical data for pricing analytics.

## 🏗 Database Schema (ER Diagram)

The system is built on a normalized schema handling **One-to-Many** and **Many-to-Many** relationships.

```mermaid
erDiagram
    FURNIZORI ||--|{ ARTICOLE : supplies
    CATEGORII ||--|{ ARTICOLE_CATEGORII : has
    ARTICOLE ||--|{ ARTICOLE_CATEGORII : categorized_as
    ARTICOLE ||--|{ STOC : located_in
    LOCATII ||--|{ STOC : stores
    ARTICOLE ||--|{ TRANZACTII : involves
    UTILIZATORI ||--|{ TRANZACTII : processes
    ARTICOLE ||--|{ ISTORIC_PRETURI : tracks

    ARTICOLE {
        int articol_id PK
        string nume
        decimal pret_curent
    }
    STOC {
        int stoc_id PK
        int cantitate
    }
    TRANZACTII {
        int tranzactie_id PK
        string tip_tranzactie
        datetime data
    }
