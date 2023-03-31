.PROGRAM prod()
;Versieregister
	;V3.0.4 28-03-2023 
		; JET 2.3.1 integratie
			; mess 018 elps request verwijdert 
			; reply 118, 119 elps OK, NOK verwijdert
	;V3.0.3.3 27-12-2022
		;Grijper sluiten bugfix: Nogmaals proberen bij status false. Na status false werd standaard de grijper weer geopend, ook al was het pakken alsnog succesvol.
	;V3.0.3.2 07-12-2022
		; bugfix. Bericht 026(voorbeeld) wordt uitgestuurd met parameters VB:26:1:2:. Jet ontvangt bericht en antwoord. Vervolgens stuurt robot 0,4 seconden later 26:0:0:0:0. Wel bericht, maar lege parameters
			; Onderzoek toont 8 gevallen aan in periode 07-11-2022 t/m 07-12-2022.
				; Oorzaak: Multithreading. bij Samengesteld bericht verzenden wordt eerst $Send[1] gereset en in de volgende line wordt mess gereset. Tussen die 2 lines in wordt voldaan aan de voorwaardes om een bericht samen te stellen in thread communicatie en wordt bericht 26 opnieuw samengesteld als 26:0:0:0
				; Oplossing: Einde CASE mess OF -> mess = -1
				; Op die manier kan nooit voldaan worden aan de voorwaardes om een nieuw bericht samen te stellen, totdat mess gereset wordt door thread samengesteld bericht verzenden.
	;V3.0.3.1 20-10-22
		; case select mess en select reply in communicatie ANY: print commando uit loop gehaald, zodat originele mess en reply fout zichtbaar blijft.
	;V3.0.3.0 05-10-22
		; Grote wijzigingen in manier van communicatie.
			; Niet meer wachten op ieder antwoord. Controleren of bericht verzonden is en dan door met volgende bericht.
			; Nieuwe structuur is als volgt.
				;in mainprog
					;wait mainprogmess == 0
					; mainprogmess = xx
				;in threadbuffer
					; if mess == 0 and mainprogmess >0
					; mainprogmess = 0
					; mess = mainprogmess
				;in communicatie 
					;if mess > 0
					; bericht samenstellen, dus $send[1] <>""
					; mess = mess + 1000
				; in autostart / verzendthread
					; if $send[1] <> "" 
					; bericht verzenden
					; $send[1] = ""
					; mess = 0, er mag een volgend bericht verzonden worden.
	;V3.0.2.4 25-08-2022
		; HALT vervangen voor Mcabort in chucknr = 1 
	;V3.0.2.3 24-08-2022
		; BUG: Als draaibank aan het draaien is, en proces wordt gestopt en tray wordt gewist, dan ontstaat er een error wanneer de draaibank klaar is met draaien. Jet wil dan draaitijd wegschrijven naar tray nummer, maar tray is leeg.
		; Fix: Bij ontvangen bericht 160 (Stop process) PCABORT 2: ;Stop DB timer monitor
	;V3.0.2.2 09-08-2022
		; Bugfix, als er meerdere berichten worden ontvangen binnen te korte tijd, dan wordt de reply parameter te snel overschreven.
			;Voorbeeld. Reply 1 komt binnen in autostart en wordt verwerkt door nr21.communicatie.
			; Reply 2 komt binnen in autostart, maar bericht 1 wordt nog verwerkt
			; Reply 3 komt binnen in autostart, nu wordt bericht 3 verwerkt i.p.v. bericht 2.
			; Oplossing: Ontvangen berichten worden nu eerst gebufferd in $recv[6] - $recv[1] en alleen $recv[1] wordt verwerkt.
			; $recv array initialiseren in nr19.parameters
	;V3.0.2.1 08-08-2022
		; achter wait commmess[6] == 0 volgnummer toegevoegd voor makkelijker debuggen vanuit PCstatus 4:
		; commmess 2 verwijdert
		; commmess omgezet naar array. vanuit communicatie loop altijd commmess[6] vullen. In threadbuffer wordt 6 naar 5 gezet, 5 naar 4, etc. commmess [1] wordt uiteindelijk verzonden.
		; commmess array initialiseren in nr19.parameters
		; parameter commsucces verwijdert. stond in value 102. Deed niets. 
	;V3.0.2.0 05-08-2022
		; DB status monitor uitgecommend
		; Na ontvangen 162 continue proces en uitvoeren mc continue 2 seconden wachttijd, zodat continue goed verwerkt wordt.
		; registerupdate grijper in nr01.buffer1vullen doen direct na aanpassen register i.p.v. na het daadwerkelijk pakken.
	;V3.0.1.0 05-08-2022
		; communicatiemess vervangen door commmess
		; Verzenden en ontvangen uit nr21.communicatie gehaald en in autostart.pc gezet. Dit voorkomt dat de communicatie vastloopt, want als de communicatieloop wacht op een antwoord, dan kan er geen antwoord ontvangen worden.
		; Opstarten van TCP/IP communicatie verplaatst naar autostart.pc
		;	Bij ontvangen 170 stop communicatie moet de TCP/IP opnieuw opengezet worden. Doordat de opstart niet in nr21.communicatie meer zit gaat dit nu met flag restart.servermode.
		;		in autostart.pc in de loop naar flag restart.servermode kijken.
		; DB status monitor en pauze controle teruggezet naar communicatieloop. 
		; Autostartmess verwijdert uit threadbuffer. 
		; DB status monitor en pauze controle mogen alleen uitgevoerd worden als communicatiemess == 0
		; String samengesteld voor debug messages
	;V3.0.0.9 04-08-2022
		; DB Status monitor en pauze controle uit communicatie gehaald en in autostart gezet. autostartmess aan thread buffer toegevoegd. 
	;V3.0.0.8 03-08-2022
		; DB status monitor wait communicatiemess == 0 was uitgecommend. Hierdoor loopt de threadbuffer vol.
	;V3.0.0.7 26-07-2022
		; proceshold status	opvragen/versturen bij starten proces. 
	;V3.0.0.6 19-07-2022
		; parameter Comloop reset naar 0 bij accepteren verbinding.
		; Fix voor vastlopen threadbuffer bij communicatiemess. Extra buffer ingebouwd commmess2, zodat de communicatieloop niet wacht op communicatiemess=0
	;V3.0.0.5 1-11-2021 TESTED
		; Fixxes in draaibank ready en niet ready binnen commloop. Bij uitzenden status niet wachtten op reply. Dit veroorzaakt een wachtloop
		; Bij commando's die Jet uitstuurt zoals START niet resetten naar mess = 0. Reset naar mess = 0 gebeurd vanuit het antwoord wat we ontvangen als wij de startbevestiging uitsturen.
	;V3.0.0.4 29-10-2021
		; reply variabele als array gedefinieerd. bij verwerking reply bijbehorende array parameter hoog zetten. na wachtpositie array parameter laag zetten
		; bij parameters initialiseren.
		; Na uitsturen mainprogmess, communicatiemess of db1timermess altijd eerst wait mainprogmess == 0, zodat de threadbuffer deze kan verwerken.
	;V3.0.0.3 29-10-2021
		; Tijdens wachten op inkomende verbinding, tray volgorde counters resetten naar startwaarden.
	;V3.0.0.2 29-10-2021
		; Comloop parameter toegevoegd bij wacht op inkomende verbinding, zodat zichtbaar is dat de loop actief is.
		; Alle print aangepast naar print 1:
	;V3.0.0.1 11-11-2020
		; Omzetting met terminator vanuit JET
	;V3.0.0.0
		; Eerste versie met TCP/IP communicatie. Verder gebasseerd op V2.1.2.3
		; Notepad ++ language Visual Basic
	
;Hoofdprogramma bij ontvangen commando EX PROD vanuit startknop Jet.

;Reset robot om storingen te voorkomen
	RESET
	
;Set trap om te stoppen op wegvallen noodsignaal draaibank
	ONI (-mach.emg) CALL nr13.stoprobot


;Startcontroles #1
	RUNMASK 26,1 					;Als programma stopt/pauzeert output 26(startknop lamp) uitschakelen.
 	CALL nr19.parameters			;Parameters inladen	
	PCABORT 2:						;Stop DB timer monitor
	TOOL grijper					;Selecteer grijperparameters uit nr19.parameters
	OPENI							;Open grijper
	SIGNAL startlamp				;Startknop lamp inschakelen

;Verstuur huidige snelheid naar JET
	Mainprogmess = 002 ;verstuur huidige snelheid SGR
	Wait mainprogmess == 0

;Aangeven naar Jet Process gestart
	Mainprogmess = 001 ;proces gestart SGR
	Wait mainprogmess == 0

;Verstuur proceshold status		
	if proceshold == 1 then
		Mainprogmess = 053	
		wait mainprogmess == 0
	else
		mainprogmess = 054
		wait mainprogmess == 0
	end

;Startcontroles #2	
	CALL nr11.checkhome				;Controleer of robot in homepositie

;Bij starten proces altijd chucknummer = 1 
	chuck.nr = firstchuck	
	
;Procescyclus starten	
	call nr00.procescyclus
	kawa.dest = 0
	call nr14.transport
	
;Proces einde,	
	IGNORE (mach.emg)				;Negeer noodsignaal draaibank
	mainprogmess = 6				;Robot: Proces afgerond. ;sgr
	WAIT mainprogmess==0			;Wacht op bevestiging
	SIGNAL -startlamp				;Startknop lamp uitschakelen
	alarm = 5
	Volgorde.counter = 0			;Reset volgorde counter.	
	tr1.volg = 30000
	tr2.volg = 30000
	tr3.volg = 30000
	tr4.volg = 30000
	tr5.volg = 30000
	tr6.volg = 30000
	HALT							;Einde programma
		
.end

.PROGRAM nr00.procescyclus()

DO
Startcycle: 								;Startlabel aan begin loop. Na uitvoeren van iedere actie begint code hier opnieuw.
TWAIT 0.1
	
;Trays bijwerken
	Call nr33.traycheck

;Buffer 1 vullen als draaibank leeg is.
	if (COB1 == 0 AND COD == 0 AND tray.nr > 0 AND chuck.nr > 0 AND proceshold == 0) Then
		if (tray.nr < 4) Then
			kawa.dest = 3
			call nr14.transport
		else
			kawa.dest = 4
			call nr14.transport		
		end
		CALL nr01.buffer1vullen
		GOTO Startcycle
	end

;Draaibank vullen
	if (COB1 > 0 AND COD == 0 AND SIG(mach.ready)) THEN
		kawa.dest = 1
		call nr14.transport
		Call nr02.draaibankvullen
		GOTO Startcycle	
	end
	
;Draaibank naar afblaasunit
	if (COD >0 AND COAU==0 AND proceshold==0 and sig(afblaas.ready)) THEN
		if (SIG(mach.ready) OR Draaibank.bijna.klaar ==1) THEN
			kawa.dest = 1
			call nr14.transport		
			CALL nr03.draaibanknaarafblaasunit
			GOTO Startcycle
		end	
	end		
	
;Draaibank naar buffer 2 als afblaasunit vol is.
	if (COD >0 AND COB2==0 AND COAU > 0 AND proceshold == 0) THEN
		if (SIG(mach.ready) OR Draaibank.bijna.klaar ==1) THEN
			kawa.dest = 1
			call nr14.transport		
			CALL nr04.draaibanknaarbuffer2
			GOTO Startcycle
		end	
	end
		
;Draaibank naar buffer 2 als proceshold actief is.
	if (COD >0 AND COB2==0 AND proceshold == 1) THEN
		if (SIG(mach.ready) OR Draaibank.bijna.klaar ==1) THEN
			kawa.dest = 1
			call nr14.transport		
			CALL nr04.draaibanknaarbuffer2
			wait proceshold == 0
			GOTO Startcycle
		end	
	end	
	
;Afblaasunit vullen als buffer 2 vol is.
	if (COB2 > 0 AND COAU ==0 AND proceshold == 0 AND sig(afblaas.ready)) THEN
		kawa.dest = 1
		call nr14.transport
		Call nr05.afblaasunitvullen
		GOTO Startcycle		
	end
	
;Afblaasunit leeghalen
	if (COAU > 0 AND sig(afblaas.ready) AND proceshold == 0) THEN
		kawa.dest = 6
		call nr14.transport
		Call nr06.afblaasunitleeghalen
		GOTO Startcycle				
	end

;Buffer 1 vullen
	if (COB1 == 0 AND tray.nr > 0 AND chuck.nr > 0 AND proceshold == 0) Then
		if (tray.nr < 4) Then
			kawa.dest = 3
			call nr14.transport
		else
			kawa.dest = 4
			call nr14.transport		
		end
		CALL nr01.buffer1vullen
		GOTO Startcycle
	end

;Als verder niets kan en draaibank is leeg.
	if (COD==0) THEN
		POINT actual = HERE
		POINT destination = #WP0
		displacement = DISTANCE(actual,destination)
		if (displacement > 10) THEN
			kawa.dest = 0
			call nr14.transport				
		end
	end
	
;Als verder niets kan en draaibank is vol.
	if (COD>0) THEN
		POINT actual = HERE
		POINT destination = #WP1
		displacement = DISTANCE(actual,destination)
		if (displacement > 10) THEN
			kawa.dest = 1
			call nr14.transport				
		end
	end	

UNTIL (tray.nr==0 AND CIG==0 AND COB1== 0 AND COB2==0 AND COD==0 AND COAU==0)

	kawa.dest = 0
	call nr14.transport	

.end

.PROGRAM nr01.buffer1vullen()

;Open grijper
	CALL nr10.grijper.open
	
;Register bijwerken voor het daadwerkelijk pakken van chuck. Hierdoor voorkomen we in nr09.grijper.sluiten een false loop.
	TIG = tray.nr
	CIG = chuck.nr
	
;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0


;Bij eerste chuck, aangeven gestart met tray en CNCtrigger sturen.
	if (CIG == firstchuck) THEN
		Print 1: "Gestart met tray.nr: ", tray.nr
		reply.array[155] = 0
		mainprogmesstray.048 = tray.nr
		mainprogmess = 048
		wait mainprogmess == 0
		wait reply.array[155] == 1
		
		CNCTRIGGEROK = 0 ; reset cnctrigger
		Print 1: "Stuur CNC voor tray.nr:", tray.nr
		mainprogmesstray.017 = tray.nr
		mainprogmessdraaibank.017 = 1
		mainprogmess = 017
		WAIT mainprogmess==0
	end	

;Calculeer te pakken positie aan hand van register grijper.
	CALL nr08.traycalc
	
;Ga naar positie en pak chuck
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE safepoint.tray		;Eerst naar veilige positie zoals berekend in traycalc
	JMOVE traypos+tray.h		;Dan naar positie boven chuck
	JMOVE traypos+tray.l
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE traypos+NULL+TRANS(0,0,-2)
	sluitproces = 1
	CALL nr09.grijper.sluiten
	LMOVE traypos+tray.h	
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
		
;Wanneer geen chuck gepakt reset grijperregister en exit functie.
	if (pakken.succes == 0) THEN
		TIG = 0
		CIG = 0 
		kawa.dest = 3
		CALL nr14.transport		
		RETURN
	end

;Controle chuck in grijper na pakken.
	if NOT SIG(grijper.open,grijper.dicht) THEN
		Print 1:"Chuck uit grijper bij tray."
		$errormess = "Grijper leeg na afhalen tray."
		mainprogmess = 011
		wait mainprogmess == 0
		HALT
	end
	
;Transport naar te plaatsen positie.		
	kawa.dest = 1
	call nr14.transport		
	
;Plaaten op positie.	
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE buffer[1]+buffer.h
	JMOVE buffer[1]+buffer.l
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE buffer[1]+NULL+TRANS(0,0,-2)
	CALL nr10.grijper.open
	LMOVE buffer[1]+buffer.h
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog

;Register bijwerken
	TOB1 = TIG
	COB1 = CIG
	TIG = 0
	CIG = 0
	
;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;Registerupdate buffer sturen	
	;parameter set
		TOB1.014 = TOB1
		COB1.014 = COB1
		mainprogmessbuffer.nr = 1
	mainprogmess = 014
	wait mainprogmess == 0
	
;Controle of CNC/trigger zenden succesvol	
	if (COB1 == firstchuck) THEN
		WAIT CNCTRIGGEROK > 0
		CASE CNCTRIGGEROK OF
			Value 1:	
				Print 1: "CNC sturen succesvol voor tray: ", TOB1
			Value 2:
				Print 1:"CNC sturen niet succesvol voor tray: ", TOB1
				CALL nr13.stoprobot
				TWAIT 5
				HALT
		end
		CNCTRIGGEROK = 0 ;Reset CNCTRIGGEROK
	end
	
;Controle of draaibank gevuld kan worden.
	if (COD == 0 AND COB1 > 0) THEN
		TIMER 10 = 0
		WAIT (SIG(mach.ready) OR (TIMER(10) > 20))
		if SIG(mach.ready) THEN
			Call nr02.draaibankvullen
			RETURN
		end
	end
	
.end

.PROGRAM nr02.draaibankvullen()

;Zet valstrik om te stoppen wanneer afzuiging naar beneden is.
	ONI (mach.afz) CALL nr13.stoprobot

;Open grijper
	CALL nr10.grijper.open
	
;Ga naar positie en pak chuck	
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE buffer[1]+buffer.h
	JMOVE buffer[1]+buffer.l	
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 	
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE buffer[1]
	sluitproces = 2
	CALL nr09.grijper.sluiten
	LMOVE buffer[1]+buffer.h
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog

;Controle chuck in grijper na pakken.
	if NOT SIG(grijper.open,grijper.dicht) THEN
		Print 1: "Chuck uit grijper bij buffer 1."
		$errormess = "Chuck uit grijper bij buffer 1."
		mainprogmess = 011
		wait mainprogmess == 0
		HALT
	end		
	
;Register bijwerken
	TIG = TOB1
	CIG = COB1
	TOB1 = 0
	COB1 = 0

;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;Registerupdate buffer sturen	
	;parameter set
		mainprogmessbuffer.nr = 1
		TOB1.014 = TOB1
		COB1.014 = COB1
	mainprogmess = 014
	wait mainprogmess == 0
	
;Transport naar te plaatsen positie.		
	kawa.dest = 1
	call nr14.transport			
	
;Plaaten op positie.
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE spindle.C				;Wachtpositie
	JMOVE spindle.B1			;inloop B met chuck in grijper
	JMOVE spindle.A1			;inloop A met chuck in grijper
	SIGNAL mach.chuckopen
		SPEED spoa.db ALWAYS;Snelheid opzetten draaibank
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accello ALWAYS	;Acceleratie medium
		DECEL accello ALWAYS	;De-acceleratie medium
	LMOVE spindle
	SIGNAL -mach.chuckopen
	TWAIT 0.2
	CALL nr10.grijper.open
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE spindle.A2			;uitloop A zonder chuck in grijper	
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE Spindle.B2			;uitloop B zonder chuck in grijper	
	JMOVE spindle.C				;Wachtpositie
	JMOVE #WP1

	
;Reset trap afzuiging.
	IGNORE (mach.afz)

;Draaibank starten en wachten tot ready off	
	pcabort 2: ;Stop DB timer monitor
	PCEXECUTE 2: nr15.startdraaibank
	
;Register bijwerken	
	TOD = TIG
	COD = CIG
	TIG = 0
	CIG = 0	
	
;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;Wacht tot draaibank ready uit is.	
	WAIT SIG(-mach.ready)
	
;registerupdate draaibank sturen	
	;parameter set
		TOD.015 = TOD
		COD.015 = COD
 	mainprogmess = 015
	wait mainprogmess == 0
	
.end

.PROGRAM nr03.draaibanknaarafblaasunit()

;Controleer of afblaasunit ready is
	if SIG(-afblaas.ready) THEN
		Print 1: "afblaasunit niet ready"
		$errormess = "afblaasunit niet ready."
		mainprogmess = 011
		wait mainprogmess == 0
		HALT
	end

;Open grijper
	CALL nr10.grijper.open
	
;Ga naar wachtpositie en wacht op ready signaal
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE spindle.C				;Wachtpositie
	TIMER 10 = 0
	WAIT (SIG(mach.ready) OR (TIMER(10) > maxwachttijd) or proceshold == 1)
	if (SIG(-mach.ready) or proceshold == 1) THEN
		Draaibank.bijna.klaar = 0
		kawa.dest = 1
		call nr14.transport	
		RETURN
	end
	
;Zet valstrik om te stoppen wanneer afzuiging naar beneden is.		
	ONI (mach.afz) CALL nr13.stoprobot
	
;Ga naar positie en pak chuck.		
	JMOVE spindle.C				;Wachtpositie
	JMOVE Spindle.B2			;inloop B zonder chuck in grijper
	JMOVE spindle.A2			;inloop A zonder chuck in grijper	
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE spindle	
	sluitproces = 2
	CALL nr09.grijper.sluiten	
	SIGNAL mach.chuckopen
	TWAIT 0.5
	LMOVE spindle.A1			;uitloop A met chuck in grijper
	SIGNAL -mach.chuckopen
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE spindle.B2			;Uitloop B met chuck in grijper
	JMOVE spindle.C				;Wachtpositie
	
;Controle chuck in grijper na pakken.
	if NOT SIG(grijper.open,grijper.dicht) THEN
		Print 1: "Chuck uit grijper bij draaibank."
		$errormess = "Chuck uit grijper bij draaibank."
		mainprogmess = 011
		wait mainprogmess == 0
		HALT
	end	

;Register bijwerken.
	TIG = TOD
	CIG = COD
	TOD = 0
	COD = 0

;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;registerupdate draaibank sturen	
	;parameter set
		TOD.015 = TOD
		COD.015 = COD
 	mainprogmess = 015
	wait mainprogmess == 0
	
;Reset trap afzuiging.
	IGNORE (mach.afz)
	
;Transport naar te plaatsen positie.		
	kawa.dest = 6
	call nr14.transport	

;Plaaten op positie.
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE afblaasunit.C
	JMOVE afblaasunit.B
	JMOVE afblaasunit.A
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE afblaasunit
	CALL nr10.grijper.open
	LMOVE afblaasunit.A
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE afblaasunit.B	
	JMOVE afblaasunit.C	
	
;Register bijwerken	
	TOAU = TIG
	COAU = CIG
	TIG = 0
	CIG = 0
	
;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;Registerupdate afblaasunit sturen
	;parameter set
		TOAU.057 = TOAU
		COAU.057 = COAU
	mainprogmess = 057
	wait mainprogmess == 0
	
;Afblaasunit starten
	PULSE afblaas.start, 1
		TIMER 10 = 0
		WAIT (SIG(-afblaas.ready) OR (TIMER(10) > 20))	
		if SIG(afblaas.ready) THEN
			Print 1: "afblaasunit niet gestart"
			$errormess = "afblaasunit niet gestart"
			mainprogmess = 011
			wait mainprogmess == 0
			HALT				
		end		
		
.end



.PROGRAM nr04.draaibanknaarbuffer2()

;Open grijper
	CALL nr10.grijper.open
	
;Ga naar wachtpositie en wacht op ready signaal
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE spindle.C				;Wachtpositie
	TIMER 10 = 0
	WAIT (SIG(mach.ready) OR (TIMER(10) > maxwachttijd))
	if SIG(-mach.ready) THEN
		Draaibank.bijna.klaar = 0
		kawa.dest = 1
		call nr14.transport	
		RETURN
	end
	
;Zet valstrik om te stoppen wanneer afzuiging naar beneden is.		
	ONI (mach.afz) CALL nr13.stoprobot
	
;Ga naar positie en pak chuck.		
	JMOVE spindle.C				;Wachtpositie
	JMOVE Spindle.B2			;inloop B zonder chuck in grijper
	JMOVE spindle.A2			;inloop A zonder chuck in grijper	
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE spindle	
	sluitproces = 2
	CALL nr09.grijper.sluiten	
	SIGNAL mach.chuckopen
	TWAIT 0.5
	LMOVE spindle.A1			;uitloop A met chuck in grijper
	SIGNAL -mach.chuckopen
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE spindle.B2			;Uitloop B met chuck in grijper
	JMOVE spindle.C				;Wachtpositie
	
;Controle chuck in grijper na pakken.
	if NOT SIG(grijper.open,grijper.dicht) THEN
		Print 1: "Chuck uit grijper bij draaibank."
			$errormess = "Chuck uit grijper bij draaibank."
			mainprogmess = 011
			wait mainprogmess == 0
			HALT	
	end	

;Register bijwerken.
	TIG = TOD
	CIG = COD
	TOD = 0
	COD = 0
	
;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;registerupdate draaibank sturen	
	;parameter set
		TOD.015 = TOD
		COD.015 = COD
 	mainprogmess = 015
	wait mainprogmess == 0
		
;Reset trap afzuiging.
	IGNORE (mach.afz)
	
;Transport naar te plaatsen positie.		
	kawa.dest = 1
	call nr14.transport		
	
;Plaaten op positie.
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog	
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE buffer[2]+buffer.h
	JMOVE buffer[2]+buffer.l
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE buffer[2]
	CALL nr10.grijper.open
	LMOVE buffer[2]+buffer.l
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog	
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE buffer[2]+buffer.h	


;Register bijwerken.
	TOB2 = TIG
	COB2 = CIG
	TIG = 0
	CIG = 0	
	
;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;Registerupdate buffer sturen	
	;parameter set
		TOB2.014 = TOB2
		COB2.014 = COB2
		mainprogmessbuffer.nr = 2
	mainprogmess = 014
	wait mainprogmess == 0	
		
.end

.PROGRAM nr05.afblaasunitvullen()

;Controleer of afblaasunit ready is
	if SIG(-afblaas.ready) THEN
		Print 1: "afblaasunit niet ready"
		$errormess = "afblaasunit niet ready"
		mainprogmess = 011
		wait mainprogmess == 0
		HALT	
	end

;Open grijper
	CALL nr10.grijper.open
	
;Ga naar positie en pak chuck	
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE buffer[2]+buffer.h
	JMOVE buffer[2]+buffer.l
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE buffer[2]
	sluitproces = 2
	CALL nr09.grijper.sluiten
	LMOVE buffer[2]+buffer.l
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog	
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE buffer[2]+buffer.h

;Controle chuck in grijper na pakken.
	if NOT SIG(grijper.open,grijper.dicht) THEN
		Print 1: "Chuck uit grijper bij buffer 2."
		$errormess = "Chuck uit grijper bij buffer 2."
		mainprogmess = 011
		wait mainprogmess == 0
		HALT	
	end	
		
;Register bijwerken
	TIG = TOB2
	CIG = COB2
	TOB2 = 0
	COB2 = 0

;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;Registerupdate buffer sturen	
	;parameter set
		TOB2.014 = TOB2
		COB2.014 = COB2
		mainprogmessbuffer.nr = 2
	mainprogmess = 014
	wait mainprogmess == 0	
	
;Transport naar te plaatsen positie.		
	kawa.dest = 6
	call nr14.transport		

;Plaaten op positie.
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE afblaasunit.C
	JMOVE afblaasunit.B
	JMOVE afblaasunit.A
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE afblaasunit
	CALL nr10.grijper.open
	LMOVE afblaasunit.A
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE afblaasunit.B	
	JMOVE afblaasunit.C	

;Afblaasunit starten
	PULSE afblaas.start, 1
		TIMER 10 = 0
	
;Register bijwerken	
	TOAU = TIG
	COAU = CIG
	TIG = 0
	CIG = 0
		
;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;Registerupdate afblaasunit sturen
	;parameter set
		TOAU.057 = TOAU
		COAU.057 = COAU
	mainprogmess = 057
	wait mainprogmess == 0
	
;Controleren of afblaasunit gestart is.
	WAIT (SIG(-afblaas.ready) OR (TIMER(10) > 20))	
	if SIG(afblaas.ready) THEN
		Print 1: "afblaasunit niet gestart"
		CALL nr13.stoprobot
		TWAIT 5
		HALT			
	end
	
.end

.PROGRAM nr06.afblaasunitleeghalen()

;Open grijper
	CALL nr10.grijper.open

;Ga naar positie en pak chuck	
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE afblaasunit.C
	JMOVE afblaasunit.B
	JMOVE afblaasunit.A
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 	
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE afblaasunit
	sluitproces = 2
	CALL nr09.grijper.sluiten
	LMOVE afblaasunit.A
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE afblaasunit.B	
	JMOVE afblaasunit.C	

;Controle chuck in grijper na pakken.
	if NOT SIG(grijper.open,grijper.dicht) THEN
		Print 1: "Chuck uit grijper bij afblaasunit."
		$errormess = "Chuck uit grijper bij afblaasunit."
		mainprogmess = 011
		wait mainprogmess == 0
		HALT	
	end	

;Register bijwerken
	TIG = TOAU
	CIG = COAU
	TOAU = 0
	COAU = 0
	
;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0
	
;Registerupdate afblaasunit sturen
	;parameter set
		TOAU.057 = TOAU
		COAU.057 = COAU
	mainprogmess = 057
	wait mainprogmess == 0
	
;Transport naar te plaatsen positie.		
	if (TIG < 4) Then
		kawa.dest = 3
		call nr14.transport
	else
		kawa.dest = 4
		call nr14.transport		
	end	

;Calculeer te plaatsen positie aan hand van register grijper.
	CALL nr08.traycalc
	
;Plaaten op positie.
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE safepoint.tray		;Eerst naar veilige positie zoals berekend in traycalc
	JMOVE traypos+tray.h		;Dan naar positie boven chuck
	JMOVE traypos+tray.l  
		SPEED spoa ALWAYS	;Snelheid opzetten afhalen
		ACCURACY accurhi ALWAYS	;Accuracy hoog
		ACCEL accelme ALWAYS	;Acceleratie medium 	
		DECEL accelme ALWAYS	;De-acceleratie medium
	LMOVE traypos+NULL+TRANS(0,0,-2) ; iets hoger loslaten
	CALL nr10.grijper.open
	LMOVE traypos+tray.l
		SPEED spha ALWAYS	;Snelheid handling
		ACCURACY accurme ALWAYS	;Accuracy medium
		ACCEL accelhi ALWAYS	;Acceleratie hoog	
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	JMOVE traypos+tray.h
	JMOVE safepoint.tray		;Eerst naar veilige positie zoals berekend in traycalc
	
;Controleer of teruggezette chuck lastchuck is.
	call nr31.checklastchuck
	
;Register bijwerken
	TIG = 0
	CIG = 0

;Registerupdate grijper sturen
	;parameter set
		TIG.016 = TIG
		CIG.016 = CIG
	mainprogmess = 016
	wait mainprogmess == 0

.end

.PROGRAM nr08.traycalc()
POINT traynull = FRAME(po[TIG],px[TIG],py[TIG],po[TIG])

;berekenen rij
	CASE CIG OF
		VALUE 1,2,3,4,5,6,7:
			rij = 1
		VALUE 8,9,10,11,12,13,14:
			rij = 2
		VALUE 15,16,17,18,19,20,21:
			rij = 3
		VALUE 22,23,24,25,26,27,28:
		rij = 4
	end
;
;       berekenen nummer in rij
nummer = CIG MOD 7
if nummer==0 THEN
nummer = 7
end
;
POINT verschuiving = NULL+TRANS(stapx[rij],stapy[nummer],0)
POINT traypos = (traynull+verschuiving)+RZ(rot[TIG])
POINT safepoint.tray = (traynull+tray.s+RZ(rot[TIG]))
.end

.PROGRAM nr09.grijper.sluiten()
; sluitproces = 1, Grijper sluiten bij tray
; sluitproces = 2, Grijper sluiten bij overige locaties


;Bij binnenkomst altijd pakken.succes op 0(false) zetten.
	pakken.succes=0

;Grijper sluiten
	TWAIT gripperwait												;Wachttijd
	CLOSEI															;Sluit grijper
	TWAIT gripperwait												;Wachttijd
	
;Bepalen of chuck succesvol gepakt
	if SIG(grijper.open,grijper.dicht) THEN							;Controleer of chuck in grijper
		pakken.succes = 1											;Ja, dan succesvol gepakt.
		Print 1: "Pakken.succes = true"
	else															;Nee, dan nogmaals proberen.
		pakken.succes = 0
		Print 1: "Pakken.succes = false"
	end
	
;Nogmaals proberen bij status false.
	if (pakken.succes == 0 ) THEN
		OPENI														;Open grijper
		TWAIT Gripperwait											;Wachttijd
		CLOSEI														;Sluit grijper
		TWAIT Gripperwait											;Wachttijd	
		if SIG(grijper.open,grijper.dicht) THEN						;Controleer of chuck in grijper
			pakken.succes = 1										;Ja, dan succesvol gepakt.
			Print 1: "Pakken.succes = true na 2e poging."
		else														;Nee, dan controle op fouten
			if SIG(-grijper.open,grijper.dicht) THEN				;Controleer of tang volledig gesloten
				pakken.succes = 0									;Ja, dan geen chuck beschikbaar.
				Print 1: "Pakken.succes = false na 2e poging."		
			else													;Nee, dan controle op fouten			
				if SIG(grijper.open,-grijper.dicht) THEN			;Controleer of tang nog open staat
					pakken.succes = 0								;Ja, dan alarm en stoppen.
					Print 1: "Grijper niet gesloten. ALARM"
					mainprogmess = 012
					wait mainprogmess == 0
					HALT
				end
			end
		end		
	end

;Als status nog steeds false is, eerst grijper openen.
	if (pakken.succes == 0) then
	 	OPENI														
		TWAIT Gripperwait											
	end

;Bij sluitproces = 1 (Grijper sluiten bij tray) 
	if (sluitproces == 1) THEN
		;Wanneer chuck succesvol gepakt.
		if (pakken.succes == 1) THEN
			chuck.nr = chuck.nr+1
			if (chuck.nr > lastchuck) THEN ;Wanneer we over lastchuck heen gaan dan: setlastchuck aanroepen
				call nr30.setlastchuck
			end
		RETURN
		end

		;Wanneer chuck niet succesvol gepakt dan: setlastchuck aanroepen, behalve bij chuck.nr == 1
		if (pakken.succes == 0) THEN
			if chuck.nr == 1 then
				Print 1: "Chuck 1 is niet beschikbaar."
				$errormess = "Chuck 1 is niet beschikbaar."
				mainprogmess = 011
				wait mainprogmess == 0
				mc abort	
				mc kill
			else
				call nr30.setlastchuck
				RETURN
			end
		end
	end
	
;Bij sluitproces = 2 (Grijper sluiten bij overige locaties) 
	if (sluitproces == 2) THEN
		;Wanneer chuck succesvol gepakt.
			if (pakken.succes == 1) THEN
				RETURN
			end
		
		;Wanneer chuck niet succesvol gepakt.
			if (pakken.succes == 0) THEN
					Print 1: "Geen chuck op locatie. ALARM"
					CALL nr13.stoprobot		
					TWAIT 5
					HALT
			end		
	end
	
;Codefout controle. Als code hier komt dan fout in bovenstaande programma.
	Print 1: "Codefout in nr09.grijper.sluiten"
	CALL nr13.stoprobot		
	TWAIT 5
	HALT
	
.end

.PROGRAM nr10.grijper.open()
	;Controleer of grijper reeds geopend is.
		if SIG(grijper.open,-grijper.dicht) THEN
			Print 1: "Grijper reeds geopend."
			RETURN
		end

	;Open grijper.
		openI
		TWAIT gripperwait
	
	;Controleer of grijper geopend is.
		if NOT SIG(grijper.open,-grijper.dicht) THEN
			Print 1: "Grijper niet geopend."
			mainprogmess = 010
			wait mainprogmess == 0
			HALT
		else
			Print 1: "Grijper geopend."
			return
		end

	;Codefout controle. Als code hier komt dan fout in bovenstaande programma.
		Print 1: "Codefout in nr10.grijper.open"
		CALL nr13.stoprobot		
		TWAIT 5
		HALT

.end

.PROGRAM nr11.checkhome

	returnhome = 0
	POINT actual = HERE
	POINT destination = #HOME(1)
	displacement = DISTANCE(actual,destination)
	if displacement>20 THEN
		alarm = 2
		mainprogmess = 020
		WAIT mainprogmess==0
		do
			if returnhome == 1 then
				returnhome = 0 
				Print 1: "Bericht returnhome ontvangen."
				CALL nr11.returnhome
				mainprogmess = 021
				wait mainprogmess == 0				
				mainprogmess = 006
				wait mainprogmess == 0
				alarm = 0
				HALT
			end
			TWAIT 0.1
		until comm == 0
		
	end
	
	kawa.loc = 0

.end

.PROGRAM nr11.returnhome()

	returntrue = 1
	SPEED 3 ALWAYS	;Snelheid hoog
	ACCURACY 0.1 ALWAYS	;Accuracy laag
	ACCEL accello ALWAYS	;Acceleratie hoog
	DECEL accello ALWAYS	;De-acceleratie hoog
	

	; positie nabij #wp1?
		POINT actual = HERE
		POINT destination = #wp1
		displacement = DISTANCE(actual,destination)
		if displacement<100 THEN
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie nabij #wp2?
		POINT actual = HERE
		POINT destination = #wp2
		displacement = DISTANCE(actual,destination)
		if displacement<100 THEN
			kawa.loc = 2
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie nabij #wp3?
		POINT actual = HERE
		POINT destination = #wp3
		displacement = DISTANCE(actual,destination)
		if displacement<100 THEN
			kawa.loc = 3
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie nabij #wp4?
		POINT actual = HERE
		POINT destination = #wp4
		displacement = DISTANCE(actual,destination)
		if displacement<100 THEN
			kawa.loc = 4
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end
		
	; positie nabij #wp6?
		POINT actual = HERE
		POINT destination = #wp6
		displacement = DISTANCE(actual,destination)
		if displacement<100 THEN
			kawa.loc = 6
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end
	
	; positie nabij buffer[1]?
		POINT actual = HERE
		POINT destination = buffer[1]
		displacement = DISTANCE(actual,destination)
		if displacement<2 THEN
			OPENI
			TWAIT 0.5
			LDEPART 35
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie boven buffer[1]?
		POINT actual = HERE
		POINT destination = buffer[1]+buffer.h
		displacement = DISTANCE(actual,destination)
		if displacement<20 THEN
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie nabij buffer[2]?
		POINT actual = HERE
		POINT destination = buffer[2]
		displacement = DISTANCE(actual,destination)
		if displacement<2 THEN
			OPENI
			TWAIT 0.5
			LDEPART 35
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie boven buffer[2]?
		POINT actual = HERE
		POINT destination = buffer[2]+buffer.h
		displacement = DISTANCE(actual,destination)
		if displacement<20 THEN
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end
		
	; positie nabij afblaasunit
		POINT actual = HERE
		POINT destination = afblaasunit
		displacement = DISTANCE(actual,destination)
		if displacement<10 THEN
			OPENI
			TWAIT 0.5
			LMOVE afblaasunit.a
			LMOVE afblaasunit.b
			LMOVE afblaasunit.c
			kawa.loc = 6
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie nabij afblaasunit A
		POINT actual = HERE
		POINT destination = afblaasunit.a
		displacement = DISTANCE(actual,destination)
		if displacement<10 THEN
			OPENI
			TWAIT 0.5
			LMOVE afblaasunit.a
			LMOVE afblaasunit.b
			LMOVE afblaasunit.c
			kawa.loc = 6
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie nabij afblaasunit B
		POINT actual = HERE
		POINT destination = afblaasunit.b
		displacement = DISTANCE(actual,destination)
		if displacement<10 THEN
			OPENI
			TWAIT 0.5
			LMOVE afblaasunit.b
			LMOVE afblaasunit.c
			kawa.loc = 6
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	; positie nabij afblaasunit C
		POINT actual = HERE
		POINT destination = afblaasunit
		displacement = DISTANCE(actual,destination)
		if displacement<10 THEN
			OPENI
			TWAIT 0.5
			LMOVE afblaasunit.c
			kawa.loc = 6
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end	

	; positie nabij wachtpositie draaimachine?
		POINT actual = HERE
		POINT destination = spindle.C
		displacement = DISTANCE(actual,destination)
		if displacement<20 THEN
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end

	;positie nabij spindle.B1?
		POINT actual = HERE
		POINT destination = spindle.B1
		displacement = DISTANCE(actual,destination)	
		if displacement<20 THEN
			JMOVE spindle.B1
			JMOVE spindle.C
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end	
		
	;positie nabij spindle.B2?
		POINT actual = HERE
		POINT destination = spindle.B2
		displacement = DISTANCE(actual,destination)	
		if displacement<20 THEN
			JMOVE spindle.B2
			JMOVE spindle.C
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end		

	;positie nabij spindle.A1?
		POINT actual = HERE
		POINT destination = spindle.A1
		displacement = DISTANCE(actual,destination)	
		if displacement<10 THEN
			JMOVE spindle.A1
			JMOVE spindle.B1
			JMOVE spindle.C
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end			
		
	;positie nabij spindle.A2?
		POINT actual = HERE
		POINT destination = spindle.A2
		displacement = DISTANCE(actual,destination)	
		if displacement<10 THEN
			JMOVE spindle.A2
			JMOVE spindle.B2
			JMOVE spindle.C
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end			
		
	;positie nabij spindle?
		POINT actual = HERE
		POINT destination = spindle
		displacement = DISTANCE(actual,destination)	
		if displacement<15 THEN
			CALL nr10.grijper.open
			LMOVE SPINDLE
			LMOVE spindle.A2
			JMOVE spindle.B2
			JMOVE spindle.C
			kawa.loc = 1
			kawa.dest = 0
			call nr14.transport
			BREAK
			RETURN
		end								


	; positie op trayveld?
		POINT #actual = HERE
		DECOMPOSE ashoek[1] = #actual
		if ((ashoek[1]>-120) AND (ashoek[1]<50)) THEN
			LDEPART 20
			HOME
			BREAK
			30          BREAK
			RETURN
		end

	; positie kan niet bepaald worden, robot moet worden geteached
		mainprogmess = 019
		WAIT mainprogmess == 0
		mainprogmess = 006
		wait mainprogmess == 0
		alarm = 1		
		HALT
.end

.PROGRAM nr13.stoprobot()
	alarm = 4 
	Print 1: "STORING: Stoprobot geactiveerd."
	PULSE 25,60
	PULSE 17,10
	HALT
.end

.PROGRAM nr14.transport()
;Posities: 0 = home, 1 = opto/buffers, 2 = ioniser, 3 = tray 1-3, 4 = tray 4-7, 6 = afblaasunit

	if (returntrue == 0) THEN
		SPEED sphi ALWAYS	;Snelheid hoog
		ACCURACY accurlo ALWAYS	;Accuracy laag
		ACCEL accelhi ALWAYS	;Acceleratie hoog
		DECEL accelhi ALWAYS	;De-acceleratie hoog
	end

	if kawa.loc==0 AND kawa.dest==0 THEN
		HOME
		kawa.loc = 0
		RETURN
	end

	if kawa.loc==0 AND kawa.dest==1 THEN
		JMOVE #wp3
		DRIVE 6,90
		JMOVE #wp1
		kawa.loc = 1
		RETURN
	end

	if kawa.loc==0 AND kawa.dest==2 THEN
		HOME
		JMOVE #wp2
		kawa.loc = 2
		RETURN
	end

	if kawa.loc==0 AND kawa.dest==3 THEN
		HOME
		JMOVE #wp3
		kawa.loc = 3
		RETURN
	end

	if kawa.loc==0 AND kawa.dest==4 THEN
		HOME
		JMOVE #wp4
		kawa.loc = 4
		RETURN
	end

	if kawa.loc==0 AND kawa.dest==6 THEN
		HOME
		JMOVE #wp6
		kawa.loc = 6
		RETURN
	end



	if kawa.loc==1 AND kawa.dest==0 THEN
		JMOVE #wp1
		DRIVE 6,45
		JMOVE #wp3
		HOME
		kawa.loc = 0
		RETURN
	end
	
	if kawa.loc==1 AND kawa.dest==1 THEN
		JMOVE #wp1
		kawa.loc = 1
		RETURN
	end	
	

	if kawa.loc==1 AND kawa.dest==2 THEN
		JMOVE #wp1
		DRIVE 6,15
		BREAK
		DRIVE 1,-66
		JMOVE #wp2
		kawa.loc = 2
		RETURN
	end

	if kawa.loc==1 AND kawa.dest==3 THEN
		JMOVE #wp1
		DRIVE 6,45
		JMOVE #wp3
		kawa.loc = 3
		RETURN
	end

	if kawa.loc==1 AND kawa.dest==4 THEN
		JMOVE #wp1
		DRIVE 6,45
		JMOVE #wp4
		kawa.loc = 4
		RETURN
	end
	
	if kawa.loc==1 AND kawa.dest==6 THEN
		JMOVE #wp1
		DRIVE 6,45
		JMOVE #wp6
		kawa.loc = 6
		RETURN
	end	

	if kawa.loc==2 AND kawa.dest==0 THEN
		JMOVE #wp2
		JMOVE #wp3
		HOME
		kawa.loc = 0
		RETURN
	end

	if kawa.loc==2 AND kawa.dest==1 THEN
		JMOVE #wp2
		DRIVE 6,90
		JMOVE #wp1
		kawa.loc = 1
		RETURN
	end
	
	if kawa.loc==2 AND kawa.dest==2 THEN
		JMOVE #wp2
		kawa.loc = 2
		RETURN
	end

	if kawa.loc==2 AND kawa.dest==3 THEN
		JMOVE #wp2
		JMOVE #wp3
		kawa.loc = 3
		RETURN
	end

	if kawa.loc==2 AND kawa.dest==4 THEN
		JMOVE #wp2
		JMOVE #wp4
		kawa.loc = 4
		RETURN
	end
	
	if kawa.loc==2 AND kawa.dest==6 THEN
		JMOVE #wp2
		JMOVE #wp6
		kawa.loc = 6
		RETURN
	end	

	if kawa.loc==3 AND kawa.dest==0 THEN
		JMOVE #wp3
		HOME
		kawa.loc = 0
		RETURN
	end

	if kawa.loc==3 AND kawa.dest==1 THEN
		JMOVE #wp3
		DRIVE 6,90
		JMOVE #wp1
		kawa.loc = 1
		RETURN
	end

	if kawa.loc==3 AND kawa.dest==2 THEN
		JMOVE #wp3
		JMOVE #wp2
		kawa.loc = 2
		RETURN
	end
	
	if kawa.loc==3 AND kawa.dest==3 THEN
		JMOVE #wp3
		kawa.loc = 3
		RETURN
	end	

	if kawa.loc==3 AND kawa.dest==4 THEN
		JMOVE #wp3
		JMOVE #wp4
		kawa.loc = 4
		RETURN
	end

	if kawa.loc==3 AND kawa.dest==6 THEN
		JMOVE #wp3
		JMOVE #wp6
		kawa.loc = 6
		RETURN
	end

	if kawa.loc==4 AND kawa.dest==0 THEN
		JMOVE #wp4
		HOME
		kawa.loc = 0
		RETURN
	end

	if kawa.loc==4 AND kawa.dest==1 THEN
		JMOVE #wp4
		DRIVE 6,90
		JMOVE #wp1
		kawa.loc = 1
		RETURN
	end

	if kawa.loc==4 AND kawa.dest==2 THEN
		JMOVE #wp4
		JMOVE #wp2
		kawa.loc = 2
		RETURN
	end

	if kawa.loc==4 AND kawa.dest==3 THEN
		JMOVE #wp4
		JMOVE #wp3
		kawa.loc = 3
		RETURN
	end
		
	if kawa.loc==4 AND kawa.dest==4 THEN
		JMOVE #wp4
		kawa.loc = 4
		RETURN
	end		
	
	if kawa.loc==4 AND kawa.dest==6 THEN
		JMOVE #wp4
		JMOVE #wp6
		kawa.loc = 6
		RETURN
	end
	
	if kawa.loc==6 AND kawa.dest==0 THEN
		JMOVE #wp6
		HOME
		kawa.loc = 0
		RETURN
	end	
	
	if kawa.loc==6 AND kawa.dest==1 THEN
		JMOVE #wp3
		DRIVE 6,90
		JMOVE #wp1
		kawa.loc = 1
		RETURN
	end

	if kawa.loc==6 AND kawa.dest==2 THEN
		JMOVE #wp6
		JMOVE #wp2
		kawa.loc = 2
		RETURN
	end		
	
	if kawa.loc==6 AND kawa.dest==3 THEN
		JMOVE #wp6
		JMOVE #wp3
		kawa.loc = 3
		RETURN
	end			
	
	if kawa.loc==6 AND kawa.dest==4 THEN
		JMOVE #wp6
		JMOVE #wp4
		kawa.loc = 4
		RETURN
	end			
	
	if kawa.loc==6 AND kawa.dest==6 THEN
		JMOVE #wp6
		kawa.loc = 6
		RETURN
	end				
	
.end

.PROGRAM nr15.startdraaibank()

	;Wisseltijd vastzetten, Timer resetten en Draaibank starten 
		Draaibank.bijna.klaar = 0
		DB1timermesswisseltijd = TIMER(1)
		TIMER 1 = 0
		PULSE (mach.f2),0.5
		TWAIT 1
		PULSE (mach.ncstart),0.5

	;wisseltijd doorgeven
		reply.array[127] = 0
		DB1timermesstray.026 = TOD
		DB1timermesschuck.026 = COD
		$DB1timermessdate.026 = $date(3)
		$DB1timermesstime.026 = $time		
		db1timermess = 026
		Wait db1timermess == 0
		wait reply.array[127] == 1
	
	;lens gestart doorgeven.
		reply.array[123] = 0
		DB1timermesstray.022 = TOD
		DB1timermesschuck.022 = COD	
		$DB1timermessdate.022 = $date(3)
		$DB1timermesstime.022 = $time
		db1timermess = 022
		Wait db1timermess == 0
		wait reply.array[123] == 1		
		
	;Korte runtime controle	
		TWAIT shortruntimealarm
		if SIG(mach.ready) Then
			Print 1: "Korte draaitijd alarm"
			$errormess = "Korte draaitijd op draaibank"
			db1timermess = 011
			Wait db1timermess == 0
			alarm = 4
			HALT	
		end
	
	;Bijna klaar loop
		DO
			checktime = (Draaitijd.draaibank - tijdvoor.BK)
			if (Timer(1) > checktime ) Then
				Print 1: "Draaibank bijna klaar"
				Draaibank.bijna.klaar = 1
			else
				Draaibank.bijna.klaar = 0
			end
		UNTIL (Draaibank.bijna.klaar == 1 OR SIG(mach.ready))


	;Draaitijd vastzetten, parameters zetten en reset timer voor wisseltijd
		WAIT SIG(mach.ready)
		DB1timermessdraaitijd = TIMER(1)
		Draaitijd.draaibank = DB1timermessdraaitijd
		DB1timermesstray.024 = TOD
		DB1timermesschuck.024 = COD	
		$DB1timermessdate.024 = $date(3)
		$DB1timermesstime.024 = $time		
		TIMER 1 = 0

	;Draaitijd doorgeven aan Jet
		reply.array[125] = 0
		db1timermess = 024
		Wait db1timermess == 0
		wait reply.array[125] == 1
	
.end

.PROGRAM nr19.parameters()

; inputs
	mach.ready = 1001; machine klaar
	mach.ack = 1002; acknowledge pc
	mach.afz = 1003; afzuiging bekrachtigd
	mach.emg = 1004; noodstop optomatic
	processtart = 1006; knop voor starten proces
	grijper.open = 1013
	grijper.dicht = 1014
	afblaas.ready = 1008 ;signaal vanuit afblaas PLC ready.
	mach.hold = 1023; knop voor stop draaien
	; error reset = 1021; dedicated ingangssignaal
	; ext cycle start = 1022; dedicated ingangssignaal
	
; outputs
	mach.ncstart = 1; startsignaal naar draaimaccurhine
	mach.chuckopen = 2; signaal tang draaimaccurhine
	mach.f2 = 3; signaal cnc oversturen
	afblaas.start = 5 ; Signaal naar afblaas PLC starten
	air.tesa = 12; TESA taster omhoog
	air.mach = 13; persluchtventiel opto
	mach.stofz = 14; stofzuiger maccurhine
	air.ion = 15; blazen met geioniseerde perslucht
	air.measure = 16; taster hoogtemeting
	beeper = 17; zoemer robotcel (instelling 00101)
	oranjelamp = 27; lamp voor attentie operator
	storing = 25; aansturing rode lamp
	startlamp = 26; knop voor start proces
	; uitgang 9 en 10 dedicated signal voor bediening grijper
	; uitgang 11 dedicated signal voor bediening lasersensor
	; motor on = 21; dedicated uitgangssignaal
	; automatic = 22; dedicated uitgangsignaal	
	
; TCP-communicatie
	Port = 8500
	ret = 0		 
	
;punten
	Point spindle.C = (spindle+NULL+TRANS(-70,-150,0,0,5,0)) ;Wachtpositie
	Point spindle.B1 = (spindle+NULL+TRANS(-0,-30,-12,0,0,0)) ;inloop B met chuck in grijper
	Point spindle.B2 = (spindle+NULL+TRANS(-0,-30,-17,0,0,0));uitloop B zonder chuck in grijper	
	Point spindle.A1 = (spindle+NULL+TRANS(-0,-0,-12,0,0,0)) ;inloop A met chuck in grijper
	Point spindle.A2 = (spindle+NULL+TRANS(-0,-0,-17,0,0,0)) ;uitloop A zonder chuck in grijper	

	Point afblaasunit.C = (afblaasunit+NULL+TRANS(0,-100,-100)) ;Inloop C afblaasunit
	Point afblaasunit.B = (afblaasunit+NULL+TRANS(0,-50,-30)) ;Inloop C afblaasunit
	Point afblaasunit.A = (afblaasunit+NULL+TRANS(0,0,-20)) ;Inloop C afblaasunit

	POINT grijper = NULL+TRANS(0.05,-91.61,92.1,89,15,90)
	POINT buffer.h = NULL+TRANS(0,0,-35); grijper hoog boven buffer
	POINT buffer.l = NULL+TRANS(0,0,-10); grijper laag boven buffer
	POINT buffer.cor = NULL+TRANS(0,0,-0.1); correctie tov. positie absorber
	POINT tray.h = NULL+TRANS(0,0,-30); grijper hoog
	POINT tray.l = NULL+TRANS(0,0,-10); grijper laag
	POINT tray.d = NULL+TRANS(0,0,-1.5); drophoogte chuck
	POINT tray.s = NULL+TRANS(0,90,-70); safepoint tray
	POINT tray.cor = NULL+TRANS(0.25,0,0); correctie tov. positie absorber
	POINT #wp0 = #PPOINT(0,-60,-128,0,-120,0)
	POINT #wp1 = #PPOINT(133,15,-145,-42,-22,115)
	POINT #wp2 = #PPOINT(67,-10,-140,0,-35,0)
	POINT #wp3 = #PPOINT(10,-30,-140,0,-55,0)
	POINT #wp4 = #PPOINT(-65,-30,-140,0,-55,0)
	POINT #wp5 = #PPOINT(80,30,-124,64,-60,0)
	SETHOME 1, #wp0
	
; bewegingsparameters
	accelhi = 100	;parameter voor acceleratie en deceleratie (% van max)
	accelme = 50	;parameter voor acceleratie en deceleratie (% van max)
	accello = 10	;parameter voor acceleratie en deceleratie (% van max)
	
	sphimax = 100			;hoge snelheid (% van max)
	sphamax = 80			;snelheid bij handling (% van max)
	spoa.dbmax = 0.3		;snelheid bij opzetten van chuck op db (% van max)
	spoamax = 3;50			;snelheid bij op- en afzetten (% van max)
	
	accurhi = 0.01	;hoge nauwkeurigheid (mm)
	accurme = 1		;medium nauwkeurigheid (mm)
	accurlo = 20	;lage nauwkeurigheid(mm)

;Timers resetten
	Timer 1 = 0 ; Draaitijd en wisseltijd
	Timer 4 = 0 ; Timer voor alarm reset 
	Timer 10 = 0 ; Timer algemeen gebruik in programma
	
;Parameters programmacontrole
	CIG = 0; actuele chuck in grijper
	TIG = 0; actuele tray in grijper
	COB1 = 0; actuele chuck op buffer 1
	TOB1 = 0; actuele tray op buffer 1
	COB2 = 0; actuele chuck op buffer 2
	TOB2 = 0; actuele tray op buffer 2
	COD = 0; actuele chuck op draaibank
	TOD = 0; actuele tray op draaibank
	COAU = 0; actuele chuck op afblaasunit
	TOAU = 0; actuele tray op afblaasunit
	tray.nr = 0
	tray1.lastchuck = 0
	tray2.lastchuck = 0
	tray3.lastchuck = 0
	tray4.lastchuck = 0
	tray5.lastchuck = 0
	
;Parameters voor communicatie
	$send[1] = ""
	restart.servermode = 0
	comm = 1
	alarm = 0
	DB1timermess = 0
	mainprogmess = 0
	mess = 0
	reply = 0
	receive.timeout = 60
	sendok = 0; 0=niet aangevraagd 1=aangevraagd 2=ok 3=fout
	
	;initialize commmess array
		FOR i = 0 to 6
			commmess[i] = 0
		end

	;initialize $recv array
		FOR i = 0 to 6
			$recv[i] = ""
		end

	;initialize reply array
		FOR i=0 TO 200
		reply.array[i] = 0
		END


;Parameters voor proces
	returntrue = 0 ; wordt in returnhome op 1 gezet om snelheid te beperken.
	Draaitijd.draaibank =1000
	tijdvoor.BK = 10
	shortruntimealarm = 10
	maxwachttijd = 20
	firstchuck = 1
	lastchuck = 28
	gripperwait = 1
	process.paused = 0

;Parameters voor palletfunctie
	stapx[1] = 0; stapmaat tussen palletposities
	stapx[2] = 35
	stapx[3] = 70
	stapx[4] = 105
	stapy[1] = 0
	stapy[2] = 30
	stapy[3] = 60
	stapy[4] = 90
	stapy[5] = 120
	stapy[6] = 150
	stapy[7] = 180
	rot[1] = 270
	rot[2] = 270
	rot[3] = 270
	rot[4] = 270
	rot[5] = 90

;Strings communicatie

.end

.PROGRAM nr20.signalering.as()

DO
	CASE alarm OF
		VALUE 0: ; Alarm uit
			SIGNAL -oranjelamp,-beeper
			
		VALUE 1:
			; Oranje lamp aan
			SIGNAL oranjelamp,-beeper
			
		VALUE 2: ; Oranje lamp interval
			SIGNAL oranjelamp,-beeper
			TWAIT 1
			SIGNAL -oranjelamp
			TWAIT 1
			
		VALUE 3: ; rode + oranje lamp interval zonder beeper. Na 300 seconden terug naar staat 4
			TIMER 4 = 0
			DO
				SIGNAL oranjelamp, storing
				TWAIT 1
				SIGNAL -oranjelamp, -storing
				TWAIT 1
				if TIMER(4)>=300 THEN
					alarm = 4
				end
			UNTIL alarm<>3
			
		VALUE 4: ; rode + oranje lamp interval + beeper 15 seconden. Daarna terug naar staat 3
			TIMER 4 = 0
			SIGNAL beeper
			DO
				SIGNAL oranjelamp,storing
				TWAIT 1
				SIGNAL -oranjelamp,-storing
				TWAIT 1
				if TIMER(4)>=15 THEN
					SIGNAL -beeper
					alarm = 3
				end
			UNTIL alarm<>4
			
		VALUE 5:
			TIMER 4 = 0
			signal oranjelamp, beeper
			DO
				TWAIT 1
				if TIMER(4)>=15 THEN
					signal -beeper
					alarm = 1
				end
			UNTIL alarm <> 5	
	end

UNTIL alarm==-1

.end

.PROGRAM nr21.communicatie() 
		
	DO ;Start communicatieloop	
		;Polling wachttijd om CPU belasting te verminderen.
		TWAIT 0.1 

	;	if commmess[1] == 0 then
	;		;Draaibank status monitor
	;		;State 1 = ready, State 2 = not ready
	;		if COD==0 then ; Alleen controleren als draaibank leeg is.
	;			if SIG(mach.ready) and SIG(mach.emg) then
	;				DBcurrentstate = 1
	;			else
	;				DBcurrentstate = 2
	;			end
	;		
	;			if dblaststate <> dbcurrentstate then
	;				if dbcurrentstate == 1 then
	;					dblaststate = 1
	;					commmess[6] = 0049
	;					wait commmess[6] == 0 ;18
	;				end
	;				if dbcurrentstate == 2 then
	;					dblaststate = 2
	;					commmess[6] = 0050
	;					wait commmess[6] == 0 ;18
	;				end				
	;			end
	;		end	

			;pauze controle
				task.info = task(1)
				if task.info == 2 then
					if process.paused == 0 then
						print 1: "Deur geopend, status naar pauze."
						process.paused = 1 
						commmess[6] = 003
						wait commmess[6] == 0 ; 1
					end
				end
	;	end		
				
		
		;Uitgaand bericht samenstellen.
		if (mess > 0 and $send[1] == "") THEN

			CASE mess OF ;Uitgaand bericht samenstellen

					VALUE 1: ;Robot: Proces gestart.
						$send[1] = "001" + " Robot: Proces gestart."
					
					VALUE 2: ;Robot: Huidige snelheid:
						if sphi	== sphimax then
							$send[1] = "002" + ":100" +  " Robot huidige snelheid: 100%"
						end
						if sphi == (0.75*sphimax) then
							$send[1] = "002" + ":75" + " Robot huidige snelheid: 75%"	
						end
						if sphi == (0.5*sphimax) then
							$send[1] = "002" + ":50" + " Robot huidige snelheid: 50%"	
						end			
						if sphi == (0.25*sphimax) then
							$send[1] = "002" + ":25" + " Robot huidige snelheid: 25%"	
						end		
						if sphi == (0.1*sphimax) then
							$send[1] = "002" + ":10" + " Robot huidige snelheid: 10%"	
						end							

					VALUE 3: ;Robot: Proces gepauzeerd.
						$send[1] = "003" + " Robot: Proces gepauzeeerd."

					VALUE 4: ;Robot: Proces gestopt.
						$send[1] = "004" + " Robot: Proces gestopt."
	
					VALUE 5: ;Robot: Proces hervat.
						process.paused = 0
						$send[1] = "005" + " Robot: Proces hervat."

					VALUE 6: ;Robot: Proces afgerond.
						$send[1] = "006" + " Robot: Proces afgerond."			

				;====================Groep 2. Procesfouten====================	
				
					VALUE 7: ;Robot: Draaibank Noodstop.
						$send[1] = "007" + ":" + $ENCODE(/L,stoprobotmessdraaibank.nr) + " Robot: Noodstop Draaibank.nr:" + $ENCODE(/L,stoprobotmessdraaibank.nr)
					
					VALUE 8: ;Robot: Geen chuck op buffer
						$send[1] = "008" + ":" + $ENCODE(/L,mainprogmessbuffer.nr) + " Robot: Geen chuck op buffer:" + $ENCODE(/L,mainprogmessbuffer.nr)
							
					VALUE 9: ;Robot: geen chuck op draaibank
						$send[1] = "009" + ":" + $ENCODE(/L,mainprogmessdraaibank.nr) + " Robot: geen chuck op draaibank_nr:" + $ENCODE(/L,mainprogmessdraaibank.nr)
					
					VALUE 10: ;Robot: grijper niet geopend.
						$send[1] = "010" + " Robot: grijper niet geopend."
							
					VALUE 11: ;Robot: algemene procesfout
						$send[1] = "011" + " Robot: algemene procesfout " + $errormess
						
					VALUE 12: ;	Robot: grijper niet gesloten.
						$send[1] = "012" + " Robot: grijper niet gesloten."
							
					VALUE 13: ;Robot: geen chuck op afblaasunit.
						$send[1] = "013" + " Robot: geen chuck op afblaasunit."
						
				;====================Groep 3. Registerupdates====================	
					
					VALUE 14: ;Robot: Register buffer bijwerken.
						if mainprogmessbuffer.nr == 1 then
							$send[1] = "014" + ":1:" + $ENCODE(/L,TOB1.014) + ":" + $ENCODE(/L,COB1.014) + " Robot: Register buffer bijwerken."
						end
						
						if mainprogmessbuffer.nr == 2 then
							$send[1] = "014" + ":2:" + $ENCODE(/L,TOB2.014) + ":" + $ENCODE(/L,COB2.014) + " Robot: Register buffer bijwerken."						
						end									
					
					VALUE 15: ;Robot: Register draaibank bijwerken. 
							$send[1] = "015" + ":1:" + $ENCODE(/L,TOD.015) + ":" + $ENCODE(/L,COD.015) + " Robot: Register draaibank bijwerken."
					
					VALUE 16: ;Robot: Register grijper bijwerken.
						$send[1] = "016" + ":" + $ENCODE(/L,TIG.016) + ":" + $ENCODE(/L,CIG.016) + " Robot: Register grijper bijwerken."
						
					VALUE 57: ;Robot: Register lenscleaner bijwerken.
						$send[1] = "057" + ":" + $ENCODE(/L,TOAU.057) + ":" + $ENCODE(/L,COAU.057) + " Robot: Register lenscleaner bijwerken."	

				;====================Groep 4. Requests====================	
					
					VALUE 17: ;Robot: Stuur CNC/trigger voor tray 
						$send[1] = "017" + ":" + $ENCODE(/L,mainprogmesstray.017) + ":" + $ENCODE(/L,mainprogmessdraaibank.017) + " Robot: Stuur CNC/trigger voor tray:" + $ENCODE(/L,mainprogmesstray.0.17) + " draaibank:" + $ENCODE(/L,mainprogmessdraaibank.017)
							;reset gebruikte parameter(s)
								mainprogmesstray.nr = 0							
								mainprogmessdraaibank.nr = 0		
								
				;====================Groep 5. Homestatus====================					
							
					VALUE 19: ;Robot: teachen nodig.
						$send[1] = "019" + " Robot: Positie niet bekend. Teach nodig."
						
					VALUE 20: ;Robot: niet in home positie.
						$send[1] = "020" + " Robot: niet in home positie."
						
					VALUE 21: ;Robot: in home positie.	
						$send[1] = "021" + " Robot: in home positie"

				;====================Groep 6. Lensstatus====================		
				
					VALUE 22: ;Robot: lens gestart.
						$send[1] = "022" + ":" + $ENCODE(/L,DB1timermesstray.022) + ":" + $ENCODE(/L,DB1timermesschuck.022) + ":" + $DB1timermessdate.022 + ":" + $DB1timermesstime.022 + " Robot: lens gestart. Tray:" + $ENCODE(/L,DB1timermesstray.022) + " chuck:" + $ENCODE(/L,DB1timermesschuck.022)
							;reset gebruikte parameter(s)
								DB1timermesstray.022 = 0							
								DB1timermesschuck.022 = 0			
								$DB1timermesstime.022 = ""
								$DB1timermessdate.022 = ""
				
					VALUE 24: ;Robot: lens klaar. Draaitijd:
						$send[1] = "024" + ":" + $ENCODE(/L,DB1timermesstray.024) + ":" + $ENCODE(/L,DB1timermesschuck.024) + ":" + $ENCODE(/L,DB1timermessdraaitijd) + ":" + $DB1timermessdate.024 + ":" + $DB1timermesstime.024 + " Robot: lens klaar. Tray:" + $ENCODE(/L,DB1timermesstray.024) + " chuck:" + $ENCODE(/L,DB1timermesschuck.024) + " draaitijd(s):" + $ENCODE(/L,DB1timermessdraaitijd)
							;reset gebruikte parameter(s)
								DB1timermesstray.024 = 0							
								DB1timermesschuck.024 = 0
								DB1timermessdraaitijd = 0
								$DB1timermesstime.024 = ""
								$DB1timermessdate.024 = ""
								
					VALUE 26: ;Robot: wisseltijd:
						$send[1] = "026" + ":" + $ENCODE(/L,DB1timermesstray.026) + ":" + $ENCODE(/L,DB1timermesschuck.026) + ":" + $ENCODE(/L,DB1timermesswisseltijd) + ":" + $DB1timermessdate.026 + ":" + $DB1timermesstime.026 + " Robot: Tray:" + $ENCODE(/L,DB1timermesstray.026) + " chuck:" + $ENCODE(/L,DB1timermesschuck.026) + " wisseltijd(s):" + $ENCODE(/L,DB1timermesswisseltijd)
							;reset gebruikte parameter(s)
								DB1timermesstray.026 = 0							
								DB1timermesschuck.026 = 0
								DB1timermesswisseltijd = 0					
								$DB1timermesstime.026 = ""
								$DB1timermessdate.026 = ""
								
				;====================Groep 10. Traystatus====================	

					VALUE 46: ;Robot: Klaar met tray:
						$send[1] = "046" + ":" + $ENCODE(/L,mainprogmesstray.046) + " Robot: Klaar met tray:" + $ENCODE(/L,mainprogmesstray.046)

					VALUE 47: ;Robot: Laatste chuck in proces voor tray:		
						$send[1] = "047" + ":" + $ENCODE(/L,mainprogmesstray.047) + " Robot: Laatste chuck in proces voor tray:" + $ENCODE(/L,mainprogmesstray.047)	
								
					VALUE 48: ;Robot: Start tray:	
						$send[1] = "048" + ":" + $ENCODE(/L,mainprogmesstray.048) + " Robot: Start tray:" + $ENCODE(/L,mainprogmesstray.048)	
			
				;====================Groep 11. Draaibankstatus====================	

					VALUE 49: ;Robot: Draaibank 1 ready for operation
						$send[1] = "049" + " Robot: Draaibank 1 ready for operation"
						
					VALUE 50: ;Robot: Draaibank 1 NOT ready for operation
						$send[1] = "050" + " Robot: Draaibank 1 NOT ready for operation"		

				;====================Groep 12. Proces hold====================			
					
					VALUE 53: ;Robot: Proces hold = on
						if proceshold == 1 then
							$send[1] = "053" + " Robot: Proces hold = on"
						else
							alarm = 4
							halt
						end
						
					VALUE 54: ;Robot: Proces hold = off
						if proceshold == 0 then
							$send[1] = "054" + " Robot: Proces hold = off"
						else
							alarm = 4
							halt
						end					
								
					VALUE 58: ; Robot: Motor is off
							$send[1] = "058" + " Robot: Motor is off"
								
				;====================DEFAULT ERROR====================									
					ANY : ;Als mess groter is dan 0, maar niet gespecificeerd is dan fout gooien. 
						Print 1: "communicatiefout. Mess bestaat niet. Mess:", mess
						do
							alarm = 4
						until comm==0

			end ;Einde CASE mess OF
			
			;Set mess to -1. see update register V3.0.3.2
				mess = -1

		end; Einde uitgaand bericht samenstellen.

		;Ontvangen bericht verwerken
		if (reply > 0 AND reply < 1000 ) THEN
			CASE reply OF

				VALUE 101: ; Jet: Proces start bevestigd.

				VALUE 102 ; Jet: Snelheid bevestigd.

				VALUE 103: ; Jet: Proces pauze bevestigd.

				VALUE 104: ; Jet: Proces gestopt bevestigd.	

				VALUE 105: ; Jet: Proces continue bevestigd.

				VALUE 106: ; Jet: Proces afgerond bevestigd.
					
				VALUE 107: ; Jet: Procesfout Draaibank fout bevestigd.

				VALUE 108: ; Jet: Procesfout geen chuck op buffer bevestigd.

				VALUE 109: ; Jet: Procesfout geen chuck op draaibank bevestigd.

				VALUE 110: ; Jet:	Procesfout Grijper niet geopend bevestigd.

				VALUE 111: ; Jet: Procesfout algemeen bevestigd.	

				VALUE 112: ; Jet: Procesfout Grijper niet gesloten bevestigd.	

				VALUE 113: ; Jet: Registerupdate buffer bevestigd.	

				VALUE 114: ; Jet: Registerupdate draaibank bevestigd.	
					
				VALUE 115: ; Jet: Registerupdate grijper bevestigd.

				VALUE 116: ; Jet: CNC trigger succesvol gestuurd.	
					CNCTRIGGEROK = 1

				VALUE 117: ; Jet: CNC trigger NIET succesvol gestuurd.
					CNCTRIGGEROK = 2

				VALUE 120: ; Jet: Robot moet geteached worden bevestigd.

				VALUE 121: ; Jet: Operator geeft aan terug naar home.	
					Returnhome = 1

				VALUE 122: ; Jet: Robot weer in home bevestigd.

				VALUE 123: ; Jet: Draaibank 1 lens gestart bevestigd.
					reply.array[123] = 1
					
				VALUE 125: ; Jet: Draaibank 1 lens klaar bevestigd.	
					reply.array[125] = 1

				VALUE 127: ; Jet: Draaibank 1 wisseltijd bevestigd.	
					reply.array[127] = 1
	
				VALUE 129: ; Jet: Tray 1 succesvol ingeladen.
					tray1.gevuld = 1
					volgorde.counter = (volgorde.counter + 1)
					tr1.volg = volgorde.counter
					
				VALUE 130: ; Jet: Tray 1 NIET succesvol ingeladen.
					tray1.gevuld = 0
					
				VALUE 131: ; Jet: Tray 2 succesvol ingeladen.
					tray2.gevuld = 1
					volgorde.counter = (volgorde.counter + 1)
					tr2.volg = volgorde.counter
					
				VALUE 132: ; Jet: Tray 2 NIET succesvol ingeladen.
					tray2.gevuld = 0

				VALUE 133: ; Jet: Tray 3 succesvol ingeladen.
					tray3.gevuld = 1
					volgorde.counter = (volgorde.counter + 1)
					tr3.volg = volgorde.counter
					
				VALUE 134: ; Jet: Tray 3 NIET succesvol ingeladen.
					tray3.gevuld = 0
					
				VALUE 135: ; Jet: Tray 4 succesvol ingeladen.
					tray4.gevuld = 1
					volgorde.counter = (volgorde.counter + 1)
					tr4.volg = volgorde.counter
					
				VALUE 136: ; Jet: Tray 4 NIET succesvol ingeladen.
					tray4.gevuld = 0				

				VALUE 137: ; Jet: Tray 5 succesvol ingeladen.
					tray5.gevuld = 1
					volgorde.counter = (volgorde.counter + 1)
					tr5.volg = volgorde.counter
					
				VALUE 138: ; Jet: Tray 5 NIET succesvol ingeladen.
					tray5.gevuld = 0

				VALUE 153: ; Jet: Tray klaar bevestigd.
					reply.array[153] = 1
					
				VALUE 154: ; Jet: Tray laatste chuck in proces bevestigd.
					reply.array[154] = 1
					
				VALUE 155: ; Jet: Tray start bevestigd
					reply.array[155] = 1

				VALUE 156: ; Jet: Alarm status
					alarm = Parameter.1

				VALUE 157: ; Jet: speedadjust
					speed.percentage = parameter.1
					if speed.percentage == 10 then
						sphi = (0.1*sphimax)
						spha = (0.1*sphamax)
						spoa.db = (0.1*spoa.dbmax)
						spoa = (0.1*spoamax)
					end
					
					if speed.percentage == 25 then
						sphi = (0.25*sphimax)
						spha = (0.25*sphamax)
						spoa.db = (0.25*spoa.dbmax)
						spoa = (0.25*spoamax)
					end
					
					if speed.percentage == 50 then
						sphi = (0.5*sphimax)
						spha = (0.5*sphamax)
						spoa.db = (0.5*spoa.dbmax)
						spoa = (0.5*spoamax)
					end
					
					if speed.percentage == 75 then
						sphi = (0.75*sphimax)
						spha = (0.75*sphamax)
						spoa.db = (0.75*spoa.dbmax)
						spoa = (0.75*spoamax)
					end
					
					if speed.percentage == 100 then
						sphi = (1.0*sphimax)
						spha = (1.0*sphamax)
						spoa.db = (1.0*spoa.dbmax)
						spoa = (1.0*spoamax)
					end		
					
					;Verzend huidige snelheid naar Jet.
					commmess[6] = 002
					wait commmess[6] == 0 ; 7		

				Value 158: ;Jet: wat is huidige status? --DEBUG CHECK functie!
					task.info = task(1)
					if task.info == 1 then
						print 1: "Huidige status = running"
						commmess[6] = 005
						wait commmess[6] == 0 ; 8
					end
					if task.info == 2 then
						print 1: "Huidige status = pause"
						commmess[6] = 003
						wait commmess[6] == 0 ; 9
					end			
					if task.info == 0 then
						print 1: "Huidige status = gestopt"
						commmess[6] = 004
						wait commmess[6] == 0 ; 10
					end		
				; Geen reset naar mess = 0 bij commando's uit jet. 

				VALUE 159: ; Jet: Start Proces. --DEBUG CHECK functie!
					task.info = switch(power)
					if task.info == -1 then
						mc execute prod
					else
						print 1: "kan niet starten, motorpower == off"
						commmess[6] = 0058
						wait commmess[6] == 0 ;11
					end
					
				VALUE 160: ; Jet: Stop Proces. --DEBUG CHECK functie!
					tray1.gevuld = 0
					tray2.gevuld = 0
					tray3.gevuld = 0
					tray4.gevuld = 0
					tray5.gevuld = 0
					mc abort	
					TWAIT 1
					mc kill
					PCABORT 2:						;Stop DB timer monitor
					commmess[6] = 004
					wait commmess[6] == 0 ;12
					
				VALUE 161: ; Jet: Pauzeer Proces. --DEBUG CHECK functie!
					process.paused = 1 
					mc abort
					commmess[6] = 003
					wait commmess[6] == 0 ; 13
					
				VALUE 162: ; Jet: Continue proces. --DEBUG CHECK functie!
					task.info = switch(power)
					if task.info == -1 then
						task.info = task(1) 
						mc continue
						twait 2 ; wacht 2 seconden, zodat proces kan hervatten.
						commmess[6] = 005
						wait commmess[6] == 0 ; 14
					else
						print 1: "kan niet starten, motorpower == off"
						commmess[6] = 058
						wait commmess[6] == 0 ; 15
					end

				VALUE 163: ; Jet: Draaibank 1 ready for operation bevestigd. --DEBUG CHECK functie!
					
				VALUE 164: ; Jet: Draaibank 1 NOT ready for operation bevestigd. --DEBUG CHECK functie!

				VALUE 167: ; Jet: Proces hold. --DEBUG CHECK functie!
					proceshold = 1
					commmess[6] = 0053
					wait commmess[6] == 0 ; 16
					
				VALUE 168: ; Jet: Proces release. --DEBUG CHECK functie!
					proceshold = 0
					commmess[6] = 0054
					wait commmess[6] == 0 ; 17

				VALUE 169: ; Jet: Registerupdate afblaasunit bevestigd.	

				VALUE 170:
					Print 1: "stop met luisteren en herstart servermodus."
					restart.servermode = 1
		
				VALUE 171: ; Jet: Tray 1 gewist.
					tray1.gevuld = 0
					tr1.volg = 30000
					
				VALUE 172: ; Jet: Tray 2 gewist.
					tray2.gevuld = 0
					tr2.volg = 30000

				VALUE 173: ; Jet: Tray 3 gewist.
					tray3.gevuld = 0
					tr3.volg = 30000	

				VALUE 174: ; Jet: Tray 4 gewist.
					tray4.gevuld = 0
					tr4.volg = 30000

				VALUE 175: ; Jet: Tray 5 gewist.
					tray5.gevuld = 0
					tr5.volg = 30000
					
				VALUE 176: ; gereserveerd voor tray 6
					do
						alarm = 4
						Print 1: "communicatiefout. reply 176 bestaat niet. reply:", reply
					until comm==0	
					
				ANY : ;Als mess groter is dan 0, maar niet gespecificeerd is dan fout gooien. 
					Print 1: "communicatiefout. reply bestaat niet. reply:", reply
				do
					alarm = 4
				until comm==0	
		
			end ;Einde CASE reply OF

			;Na verwerken reply, reply standaard op reply + 1000
			reply = (reply + 1000)
			
		end ;Einde ontvangen bericht verwerken.
		
	UNTIL comm==0 ;Einde communicatieloop	
	
.end

.PROGRAM nr22.threadbuffer()
	DO
		Beginning:
		TWAIT 0.2 ;debug
	
		if mainprogmess > 0 and mess == 0 then
			Print 1: "Debug mainprogmess =", mainprogmess
			mess = mainprogmess
			mainprogmess = 0
			GOTO Beginning
		end

		if DB1timermess > 0 and mess == 0 THEN
			Print 1: "Debug DB1timermess =", DB1timermess
			mess = db1timermess
			db1timermess = 0
			GOTO Beginning
		end
		
		if commmess[1] > 0 and mess == 0  then 
			Print 1: "Debug commmess[1] = ", commmess[1]
			mess = commmess[1]
			commmess[1] = 0
			GOTO Beginning
		end

		;commmess array buffer
			if commmess[6] > 0 and commmess[5] == 0 then
				commmess[5] = commmess[6]
				commmess[6] = 0
			end
		
			if commmess[5] > 0 and commmess[4] == 0 then
				commmess[4] = commmess[5]
				commmess[5] = 0
			end	
	
			if commmess[4] > 0 and commmess[3] == 0 then
				commmess[3] = commmess[4]
				commmess[4] = 0
			end	

			if commmess[3] > 0 and commmess[2] == 0 then
				commmess[2] = commmess[3]
				commmess[3] = 0
			end	
		
			if commmess[2] > 0 and commmess[1] == 0 then
				commmess[1] = commmess[2]
				commmess[2] = 0
			end			
		

	;Debug string voor debug messages
	$messages = "mess=" + $ENCODE(/L,mess)  + " mainprogmess=" + $ENCODE(/L,mainprogmess) + " DB1timermess=" + $ENCODE(/L,DB1timermess) + " commmess[1]=" + $ENCODE(/L,commmess[1])
	;Debug string voor debug commmess array
	$commmessages = "commmess[1]" + $ENCODE(/L,commmess[1])  + " commmess[2]" + $ENCODE(/L,commmess[2]) + " commmess[1]" + $ENCODE(/L,commmess[3]) + " commmess[1]" + $ENCODE(/L,commmess[4])  + " commmess[5]" + $ENCODE(/L,commmess[5]) + " commmess[6]" + $ENCODE(/L,commmess[6])  
	
		
	UNTIL comm==0
.end

.PROGRAM nr23.parse.received()
	pos = 0
	messagecode = 0
	Parameter.1 = 0
	Parameter.2 = 0
	Parameter.3 = 0
	Parameter.4 = 0

	;Verwijder Human readable tekst. zoek positie van spatie en gooi alles rechts van spatie weg.
		pos = INSTR($recv[1]," ")
		if pos > 0 then
			$recv[1] = $LEFT($recv[1],(pos-1))
			Print 1: "$recv[1] na parse 1:",$recv[1]
		else
			Print 1: "Geen spatie in ontvangen bericht."
			alarm = 4
			HALT
		end
		
	;Parse messagecode. Zoek positie van eerste : in resterende string
		pos = INSTR($recv[1], ":")
		if pos > 0 then
			messagecode = VAL($LEFT($recv[1],(pos-1)))				;Zet messagecode op alles links van :
			$recv[1] = $RIGHT($recv[1],LEN($recv[1])-pos)			;Verwijder alles links van: FOUT
			Print 1: "Messagecode= ",messagecode
		else
			if VAL($recv[1]) > 0 then
				messagecode = VAL($recv[1])
				Print 1: "Messagecode= ",messagecode
				RETURN
			else
				Print 1: "Geen messagecode in ontvangen bericht."
				alarm = 4
				HALT
			end
		end

	;Parse parameter.1. Zoek positie van eerste : in resterende string
		pos = INSTR($recv[1], ":")
		if pos > 0 then
			parameter.1 = VAL($LEFT($recv[1],(pos-1)))				;Zet parameter.1 op alles links van :
			$recv[1] = $RIGHT($recv[1],LEN($recv[1])-pos)			;Verwijder alles links van: 
			Print 1: "parameter.1= ",parameter.1
		else
			if VAL($recv[1]) > 0 then
				parameter.1 = VAL($recv[1])
				Print 1: "parameter.1= ",parameter.1, " Geen volgende parameter gevonden."
				RETURN
			else
				Print 1: "Geen parameter.1 in bericht"
				RETURN
			end
		end

	;Parse parameter.2. Zoek positie van eerste : in resterende string
		pos = INSTR($recv[1], ":")
		if pos > 0 then
			parameter.2 = VAL($LEFT($recv[1],(pos-1)))				;Zet parameter.2 op alles links van :
			$recv[1] = $RIGHT($recv[1],LEN($recv[1])-pos)			;Verwijder alles links van:
			Print 1: "parameter.2= ",parameter.2
		else
			if VAL($recv[1]) > 0 then
				parameter.2 = VAL($recv[1])
				Print 1: "parameter.2= ",parameter.2, " Geen volgende parameter gevonden."
				RETURN
			else
				Print 1: "Geen parameter.2 in bericht"
				RETURN
			end
		end				
				
	;Parse parameter.3. Zoek positie van eerste : in resterende string
		pos = INSTR($recv[1], ":")
		if pos > 0 then
			parameter.3 = VAL($LEFT($recv[1],(pos-1)))				;Zet parameter.3 op alles links van :
			$recv[1] = $RIGHT($recv[1],LEN($recv[1])-pos)			;Verwijder alles links van:
			Print 1: "parameter.3= ",parameter.3
		else
			if VAL($recv[1]) > 0 then
				parameter.3 = VAL($recv[1])
				Print 1: "parameter.3= ",parameter.3, " Geen volgende parameter gevonden."
				RETURN
			else
				Print 1: "Geen parameter.3 in bericht"
				RETURN
			end
		end				
				
	;Parse parameter.4. Zoek positie van eerste : in resterende string
		pos = INSTR($recv[1], ":")
		if pos > 0 then
			parameter.4 = VAL($LEFT($recv[1],(pos-1)))				;Zet parameter.4 op alles links van :
			$recv[1] = $RIGHT($recv[1],LEN($recv[1])-pos)			;Verwijder alles links van:
			Print 1: "parameter.4= ",parameter.4
		else
			if VAL($recv[1]) > 0 then
				parameter.4 = VAL($recv[1])
				Print 1: "parameter.4= ",parameter.4, " Geen volgende parameter gevonden."
				RETURN
			else
				Print 1: "Geen parameter.4 in bericht"
				RETURN
			end
		end
	
.end

.program nr30.setlastchuck
;lastchuck van deze tray instellen op chuck.nr-1, doorgeven laastste chuck in proces, tray.nr resetten naar 0 , chuck.nr resetten naar 1.

;Lastchuck tray instellen
	if tray.nr == 1 then
		tray1.lastchuck = (chuck.nr - 1)
		mainprogmesstray.047 = 1
	end
	
	if tray.nr == 2 then
		tray2.lastchuck = (chuck.nr - 1)
		mainprogmesstray.047 = 2
	end				
	
	if tray.nr == 3 then
		tray3.lastchuck = (chuck.nr - 1)
		mainprogmesstray.047 = 3
	end					
	
	if tray.nr == 4 then
		tray4.lastchuck = (chuck.nr - 1)
		mainprogmesstray.047 = 4
	end	
	
	if tray.nr == 5 then
		tray5.lastchuck = (chuck.nr - 1)
		mainprogmesstray.047 = 5
	end					
				
	;Doorgeven laatste chuck in proces
		print 1: "Tray:",tray.nr," laatste chuck in proces:", (chuck.nr - 1)
		reply.array[154] = 0
		mainprogmess = 047
		wait mainprogmess == 0
		wait reply.array[154] == 1		
		
	;tray.nr resetten naar 0
		tray.nr = 0
				
	;chuck.nr resetten.
		chuck.nr  = firstchuck
.end

.program nr31.checklastchuck
	;reset mainprogmesstray.046
		mainprogmesstray.046 = 0

	;controleren of tray gereed.
	
	if TIG == 1 and CIG == tray1.lastchuck then
		print 1: "Tray 1 laatste chuck teruggezet. Eind tray 1."
		tray1.lastchuck = 0
		mainprogmesstray.046 = TIG
	end

	if TIG == 2 and CIG == tray2.lastchuck then
		print 1: "Tray 2 laatste chuck teruggezet. Eind tray 2."
		tray2.lastchuck = 0
		mainprogmesstray.046 = TIG
	end

	if TIG == 3 and CIG == tray3.lastchuck then
		print 1: "Tray 3 laatste chuck teruggezet. Eind tray 3."
		tray3.lastchuck = 0
		mainprogmesstray.046 = TIG
	end

	if TIG == 4 and CIG == tray4.lastchuck then
		print 1: "Tray 4 laatste chuck teruggezet. Eind tray 4."
		tray4.lastchuck = 0
		mainprogmesstray.046 = TIG
	end
	
	if TIG == 5 and CIG == tray5.lastchuck then
		print 1: "Tray 5 laatste chuck teruggezet. Eind tray 5."
		tray5.lastchuck = 0
		mainprogmesstray.046 = TIG
	end	


	;Als mainprogmesstray.046 geen 0 is dan aangeven tray gereed.
	if mainprogmesstray.046 > 0 
		reply.array[153] = 0
		mainprogmess = 046
		wait mainprogmess == 0
		wait reply.array[153] == 1
	end
	
	
.end

.program nr33.traycheck

		if tray.nr == 0 then
			if tray1.gevuld == 1 then
				if tr1.volg < tr2.volg and tr1.volg < tr3.volg and tr1.volg < tr4.volg and tr1.volg < tr5.volg then
					tray1.gevuld = 0
					tr1.volg = 30000
					tray.nr = 1
					print 1: "Tray 1 is actief."
					RETURN
				end
			end
			if tray2.gevuld == 1 then
				if tr2.volg < tr1.volg and tr2.volg < tr3.volg and tr2.volg < tr4.volg and tr2.volg < tr5.volg then
					tray2.gevuld = 0
					tr2.volg = 30000
					tray.nr = 2
					print 1: "Tray 2 is actief."
					RETURN
				end
			end			
			if tray3.gevuld == 1 then
				if tr3.volg < tr1.volg and tr3.volg < tr2.volg and tr3.volg < tr4.volg and tr3.volg < tr5.volg then
					tray3.gevuld = 0
					tr3.volg = 30000
					tray.nr = 3
					print 1: "Tray 3 is actief."
					RETURN
				end
			end					
			if tray4.gevuld == 1 then
				if tr4.volg < tr1.volg and tr4.volg < tr2.volg and tr4.volg < tr3.volg and tr4.volg < tr5.volg then
					tray4.gevuld = 0
					tr4.volg = 30000
					tray.nr = 4
					print 1: "Tray 4 is actief."
					RETURN
				end
			end				
			if tray5.gevuld == 1 then
				if tr5.volg < tr1.volg and tr5.volg < tr2.volg and tr5.volg < tr3.volg and tr5.volg < tr4.volg then
					tray5.gevuld = 0
					tr5.volg = 30000
					tray.nr = 5
					print 1: "Tray 5 is actief."
					RETURN
				end
			end					
		end


.end


.PROGRAM autostart.pc()

	PCEXECUTE 3: nr20.signalering	;Start signalering
	PCEXECUTE 4: nr21.communicatie	;Start communicatie
	PCEXECUTE 5: nr22.threadbuffer	;Start threadbuffer

	;Roep parameters op bij herstarten robot
		call nr19.parameters
		Comloop = 0
	
	;Start servermodus
		Listen: 
		Print 1: "Start Servermode"
		TCP_LISTEN ret, Port
		if ret==0 then
			Print 1: "Servermodus succesvol gestart."
		else
			Print 1: "Servermodus niet succesvol gestart."
		end		

	;Wacht op inkomende TCP/IP verbinding
		Accept:
		;Reset volgorde counters. Zodat bij nieuwe verbinding niet met verkeerde tray gestart wordt.
			Volgorde.counter = 0			;Reset volgorde counter inscannen trays.	
			tr1.volg = 30000
			tr2.volg = 30000
			tr3.volg = 30000
			tr4.volg = 30000
			tr5.volg = 30000
			tr6.volg = 30000
			comloop = comloop + 1 ;Comloop counter + 1
			Print 1: "Wacht op inkomende verbinding", comloop
			TCP_ACCEPT SocketID, Port,5,ip[1]
			if SocketID > 0 then
				Print 1: "Inkomende verbinding geaccepteerd"
				comloop = 0
			else
				Print 1: "Geen inkomende verbinding. probeer opnieuw" 
				GOTO Accept
			end	

	DO ;Start Ontvangst en verzend loop	
		;Polling wachttijd om CPU belasting te verminderen.
			TWAIT 0.1 
		
		;Servermodus herstarten na ontvangen reply 170	
			if restart.servermode == 1 then
				restart.servermode = 0
				TCP_END_LISTEN ret, port	
				Print 1: "close socket:", socketID
				TCP_CLOSE ret, socketid
				Print 1: "socket closed"
				goto listen		
			end
		
		;Samengesteld bericht verzenden
			if ($send[1] <> "" ) THEN
				Print 1: "$send[1] = ",$send[1]
				$send[1] = $send[1] + "\n" ; terminator toevoegen
				TCP_SEND ret, SocketID, $send[1], nrecv, 1
				if ret == 0 then
					$send[1] = ""
					mess = 0 ; bericht is verzonden, dus klaar voor volgende.			
				else
					Print 1: "Bericht niet succesvol verzonden."
					Print 1: "Geen verbinding met JET. Wacht op inkomende verbinding."
					GOTO Accept ;debug. Wat is de logica van deze GOTO? Doet niets. SGR 19-07-2022
				end
			end; Einde uitgaand bericht versturen.

		;Bericht ontvangen
			TCP_RECV ret, SocketID, $recv[6], nrecv, 1, 255
			if ret == 0 then
				Print 1: "$recv[6] = ", $recv[6]
				;DEBUG SocketID controle
					if socketID > 13 then
						do
							Alarm = 4
							Print 1: "SocketID is geen 13. SocketID:", SocketID
						until comm == 0
					end
			else ; testen door stroom uit PC jet te trekken.
				if ret == -34025
					Print 1:"geen verbinding."	
					Print 1:"stop met luisteren"
					TCP_END_LISTEN ret, port	
					Print 1:"close socket:", SocketID
					TCP_CLOSE ret, SocketID
					Print 1:"socket closed"
					Print 1:"Herstart servermodus"
					GOTO listen
				end
			end
		
		;Ontvangen bericht bufferen
		;$recv array buffer
			if $recv[6] <> "" and $recv[5] == "" then
				$recv[5] = $recv[6]
				$recv[6] = ""
			end
		
			if $recv[5] <> "" and $recv[4] == "" then
				$recv[4] = $recv[5]
				$recv[5] = ""
			end	
	
			if $recv[4] <> "" and $recv[3] == "" then
				$recv[3] = $recv[4]
				$recv[4] = ""
			end	

			if $recv[3] <> "" and $recv[2] == "" then
				$recv[2] = $recv[3]
				$recv[3] = ""
			end	
		
			if $recv[2] <> "" and $recv[1] == "" then
				$recv[1] = $recv[2]
				$recv[2] = ""
			end					
		
		;Ontvangen bericht verwerken
			if $recv[1] <> "" then
				call nr23.parse.received
				reply = messagecode
				Print 1: "reply = ", reply		
				$recv[1] = ""	
			end
			

	UNTIL comm==0 ;Einde Ontvangst en verzend loop

.end


