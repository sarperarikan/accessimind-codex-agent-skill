# Starter Prompts

Bu dosya, OpenClaw ve Codex tarafinda ayni audit akisini baslatmak icin hazir baslangic promptlarini icerir.

Kullanim mantigi:
- `{{URL}}`, `{{URL_1}}`, `{{URL_2}}` gibi alanlari kendi site adreslerinizle degistirin.
- Tek komutluk audit istiyorsaniz ayni-domain kesif ve rapor birlestirme beklentisini koruyun.
- Gercek blind persona kaniti gerekiyorsa `Windows NVDA worker verisini birlestir` ifadesini ekleyin.

## 1. OpenClaw varsayilan audit

```text
{{URL}} icin OpenClaw destekli erisilebilirlik denetimi yap. Tarama baslarken gercek Chrome kullan, rendered DOM incele, keyboard ve focus kaniti topla, screenshot al, stateful bilesenleri etkilesimli tara ve bulgulari tam rapor olarak kaydet.
```

## 2. Ayni domain kesfi ile audit

```text
{{URL}} icin erisilebilirlik denetimi yap. Ayni domain altinda kullanici akisina gore en onemli 3 sayfayi kesfet, sonra her sayfada Chrome tabanli canli audit calistir, bulgulari tek raporda topla ve raporu kaydet.
```

## 3. Persona odakli derin audit

```text
{{URL}} icin erisilebilirlik denetimi yap. Blind, low-vision ve motor persona acisindan incele. Once cookie dialog varsa degerlendir ve kabul et, sonra sayfayi bastan sona tara, screenshot ve focus kaniti topla, duzeltme yonlerini Dev/BA/PO aksiyonlariyla raporla.
```

## 4. Windows NVDA worker birlestirmeli audit

```text
{{URL}} icin erisilebilirlik denetimi yap. Chrome tarafinda canli audit calistir, sonra Windows NVDA worker verisini birlestir ve nihai raporda heuristik blind yorum ile gercek screen reader kanitini ayir.
```

## 5. Belirli URL listesi ile audit

```text
Su sayfalar icin erisilebilirlik denetimi yap: {{URL_1}}, {{URL_2}}, {{URL_3}}. OpenClaw varsayilan davranisini kullan, canli DOM ve keyboard taramasi yap, bulgulari tek raporda birlestir ve ciktilari kaydet.
```

## 6. Yonetici ozeti ve teknik rapor

```text
{{URL}} icin erisilebilirlik denetimi yap. Kisa ozet degil, yonetici ozeti, teknik bulgular, WCAG etkileri, tekrar eden sorun kumeleri ve oncelikli aksiyon plani iceren tam rapor uret. Ayni domain altinda kritik sayfalari otomatik sec ve ciktilari kaydet.
```

## 7. NVDA odakli dogrulama

```text
{{URL}} icin blind persona odakli erisilebilirlik denetimi yap. OpenClaw ile gercek Chrome oturumu uzerinde gezin, sonra Windows NVDA worker veya portable NVDA verisiyle link, button, form ve landmark davranisini dogrula. Sonucu raporla ve kaydet.
```

## 8. Hizli kurumsal varsayilan

```text
{{URL}} icin erisilebilirlik denetimi yap. Ayni domain altinda onemli sayfalari sec, canli Chrome taramasi, keyboard/focus denetimi, screenshot, persona analizi ve rapor birlestirme adimlarini otomatik calistir. Bulgulari tam rapor olarak kaydet.
```

## Kisa notlar

- Eger sadece kok sayfa denetlenecekse `RootOnly` mantigini isteyin.
- Eger mevcut bir Windows NVDA worker JSON cikti dosyasi varsa rapora birlestirilmesini acikca yazin.
- Eger uzun rapor istiyorsaniz `kisa ozet degil, tam rapor uret` cumlesini koruyun.
- Eger sayfa kesfi istenmiyorsa URL'leri tek tek verin.
