# YellowBloom Café
Proiectul reprezintă un site pentru un cat café. Am ales această temă pentru că în viitorul îndepărtat aș vrea să deschid un astfel de local.

## Pagini
Inițial proiectul are următoarele pagini:
1. **Acasă**: informații generale despre local
2. **Meniu** 
3. **Galerie**: poze cu localul și pisicile rezidente
4. **Cont**: pagina în care un utilizator se poate înrehistra/gestiona contul

5. **tmpAngajat**: în cazul în care utilizatorul care se înregistrează este angajat, această pagină va apărea pentru gestiunea localului

## Roluri utilizatori:
1. **Guest**: Nu necesită logare. Poate vizualiza paginile 1, 2, 3, 4
2. **Utilizator**: Poate face rezervări și comenzi online
3. **Angajat**: Gestionează localul (marchează mesele rezervate/ocupate, modifică disponibilitatea produselor ...)
3. **Manager**: Poate vedea utilizatorii și modifica stocul


# Aplicație Ruby on Rails

Aceasta este o aplicație web construită cu **Ruby on Rails**, utilizând Hotwire.

## Cerințe de sistem

- **Ruby**: versiunea `3.4.2`
- **Bundler**: versiunea cea mai recentă (`gem install bundler`)
- **SQLite3**
- **Node.js** și **Yarn** (necesare pentru Tailwind și JavaScript runtime)

## Instalare și configurare:

### 1. Instalează Ruby 3.4.2

Puteți instala Ruby folosind linkul https://www.ruby-lang.org/en/downloads/

```bash
ruby -v
# => ruby 3.4.2 (2025-02-15 ...)
```

2. Clonează proiectul
```bash
git clone https://github.com/LeuConstantinCatalin/YellowBloomCafe.git
```

3. Instalează dependențele
```bash
bundle install
```

4. Instalează JavaScript runtime și Tailwind
```bash
rails tailwindcss:install
```

5. Inițializează baza de date
```bash
rails db:setup
```

6. Pornirea serverului
```bash
rails server
```
Serverul va porni si site-ul va putea fi accesat la http://127.0.0.1:3000

Default, serverul pornește in modul development, ceea ce face responsivitatea mică.

Pentru a creste responsivitatea, serverul trebuie pornit în modul producție astfel:

```bash
set RAILS_ENV=production
rails assets:precompile
rails server -b 127.0.0.1 -p 3000
```