; *** Formatted for MAGICKAL v4p9 onward!!! ***

; I set this up for the big hot core grid data
; Use 'file_list.txt' to enter the file paths you want to load from

; Give target datafile

rpath='/Users/ep9k/Desktop/'

rname='op_output.d'

;number of depth points, how many separate output files to read
ndp=1

;;----------------------------------------------
; Comment out this bit if there is no file list
; i.e. to just load one file (using rname above)
;;----------------------------------------------
lname='best_models.txt'
;lname='file_list_allzeta_lowbarrier.txt'
;lname='file_list_barrier_short.txt'
;lname='file_list_allzeta.txt'
;lname='file_list_z100_2d11.txt'
;lname='file_list_iras.txt'

;tmax is max time points in model, different for each timescale. tmaxmax is the maximum points to make an array. If timescale doesnt require that many, goes as zero
tmaxmax=1600

llines=6

;reads lname file
OPENR, 1, rpath+lname

dum=''
files=STRARR(1000)

FOR i=0,llines-1 DO BEGIN
   READF, 1, FORMAT = '(A50)',dum
   files[i]=STRTRIM(dum,2)
ENDFOR

CLOSE, 1

ndp=llines
print, files[0]

rname=files[0]+'op_output.d'
;----------------------------------------------
;----------------------------------------------


OPENR, 1, rpath+rname

; Switch for loading colours in other programs later
ld=0

dummy1=STRARR(12)
dumhead=''
idens=0
itemp=0
iself=0
iplay=0
specs=STRARR(10)
a=STRARR(10)
; default values
gd=1.d+12
tns=1.d+6

;this section reads the header file. The tag tells the script when to stop. make sure that script can find these headers even if number of lines change. 
tag=0
FOR n=1,200 DO BEGIN
   IF (tag EQ 0) THEN BEGIN
      READF, 1, FORMAT = '(A2,51X,A8,2X,A12,2X,A5,1X,9A1)',dumhead,dummy1
      dummy1=STRTRIM(dummy1,2)
      IF (dummy1[2] EQ 'IDENS') AND (dummy1[1] EQ 'YES') THEN idens=1
      IF (dummy1[2] EQ 'ITEMP') AND (dummy1[1] EQ 'YES') THEN itemp=1
      IF (dummy1[2] EQ 'ISELF') AND (dummy1[4] EQ '2') THEN iself=2
      IF (dummy1[2] EQ 'IPLAY') AND (dummy1[4] GT '0') THEN iplay=1
      IF (dummy1[0] EQ 'NSMAX') THEN nsmax=FIX(dummy1[1])
      IF (dummy1[0] EQ 'NSGAS') THEN nsgas=FIX(dummy1[1])
      IF (dummy1[0] EQ 'NSGRAIN') THEN nsgrain=FIX(dummy1[1])
      IF (dummy1[0] EQ 'NEMAX') THEN nemax=FIX(dummy1[1])
      IF (dummy1[0] EQ 'GD') THEN gd=DOUBLE(dummy1[1]) 
      IF (dummy1[0] EQ 'TNS') THEN tns=DOUBLE(dummy1[1]) 
      IF (dummy1[0] EQ 'NT') THEN BEGIN
        tmax=FIX(dummy1[1])
        tag=1
        READF, 1, FORMAT = '(A2)',dumhead
      ENDIF
   ENDIF
ENDFOR

iself=0

;set up arrays to contain data
name=STRARR(nsmax)
pname=name
xn=FLTARR(nsmax,tmaxmax,ndp)
;xm=xn
;xr=xm
timval=FLTARR(tmaxmax,ndp)
IF (idens EQ 1) OR (itemp EQ 1) OR (iself EQ 2) THEN BEGIN
   xnt=FLTARR(tmaxmax,ndp)
   temp=FLTARR(tmaxmax,ndp)
   dtemp=FLTARR(tmaxmax,ndp)
;   tau=FLTARR(tmaxmax,ndp)
   zeta=FLTARR(tmaxmax,ndp)
;   zeta=FLTARR(ndp)
;   cdh2=FLTARR(tmaxmax,ndp)
;   cdco=FLTARR(tmaxmax,ndp)
;   dist=FLTARR(tmaxmax,ndp)
;   rx=FLTARR(tmaxmax,ndp)
;   rz=FLTARR(tmaxmax,ndp)
   tmaxs=INTARR(ndp)
ENDIF ELSE BEGIN
   xnt=FLTARR(1,ndp)
   temp=FLTARR(1,ndp)
   dtemp=FLTARR(1,ndp)
;   tau=FLTARR(1,ndp)
   zeta=FLTARR(1,ndp)
;   cdh2=FLTARR(1,ndp)
;   cdco=FLTARR(1,ndp)
;   dist=FLTARR(1,ndp)
;   rx=FLTARR(1,ndp)
;   rz=FLTARR(1,ndp)
   tmaxs=INTARR(ndp)
ENDELSE

j=0
; Read data from file
tmaxs[j]=tmax
IF (idens EQ 1) OR (itemp EQ 1) OR (iself EQ 2) THEN BEGIN
   tag=0
   FOR n=1,5000 DO BEGIN
      IF (tag EQ 0) THEN BEGIN
         READF, 1, FORMAT = '(A2,1X,A5,22X,A11,3X,A11,4X,A11,4X,A9,6X,A11,6X,A8,6X,A8,6X,A11,4X,A12,4X,A12)', dummy1
         dummy1=STRTRIM(dummy1,2)
         IF (dummy1[0] EQ 'IT') THEN BEGIN
            it=FIX(dummy1[1])-1
            xnt[it,j]=DOUBLE(dummy1[2])
            temp[it,j]=DOUBLE(dummy1[3])
            dtemp[it,j]=DOUBLE(dummy1[4])
;            tau[it,j]=DOUBLE(dummy1[5])
            zeta[it,j]=DOUBLE(dummy1[6])
;            zeta[j]=DOUBLE(dummy1[6])
;            cdh2[it,j]=DOUBLE(dummy1[7])
;            cdco[it,j]=DOUBLE(dummy1[8])
;            dist[it,j]=DOUBLE(dummy1[9])
;            rx[it,j]=DOUBLE(dummy1[10])
;            rz[it,j]=DOUBLE(dummy1[11])
            IF (it EQ tmax-1) THEN tag=1
         ENDIF
      ENDIF
   ENDFOR
ENDIF

; skip data about errors for elements
tag=0
FOR n=1,100 DO BEGIN
   IF (tag EQ 0) THEN BEGIN
      READF, 1, FORMAT = '(41X,A4,9A1)', dummy1
      dummy1=STRTRIM(dummy1,2)
      IF (dummy1[0] EQ 'P')AND(nemax NE 13) THEN tag=1
      IF (dummy1[0] EQ 'D')AND(nemax EQ 13) THEN tag=1
   ENDIF
ENDFOR
;READF, 1, FORMAT = '(1X)'

;read abundance data for each segment of 10 molecules. m can vary if it gets to the end and there are less than 10 molecules in a line.
FOR k=0,nsmax-1,10 DO BEGIN
   m=k+9
   IF (m GT nsmax-1) THEN m=nsmax-1
   READF, 1, FORMAT = '(/)'
   READF, 1, FORMAT = '(/)'
   READF, 1, FORMAT='(19X,10(1X,A8,2X,:))', specs
   name[k:m]=specs[0:m-k]
   FOR l=0, tmax-1 DO BEGIN
      READF, 1, FORMAT='(6X,A11,1X,10(A11))',tim,a
      timval[l,j]=DOUBLE(tim)
      xn[k:m,l,j]=DOUBLE(a[0:m-k])
   ENDFOR
   READF, 1, FORMAT = '(/)'
ENDFOR

;ice layer composition, iplay prints layer composition, fraction of new material in the bulk for that species, used for G22 comp. vs layers, good for prestellar core
; in output this prints as "TIME EVOLUTION OF MANTLE"
IF ((iplay EQ 1) OR (IPLAY EQ 3)) THEN BEGIN
  FOR k=0,nsgrain-1,10 DO BEGIN
     kk=k+nsgas+nsgrain
     m=k+9
     mm=kk+9
     IF (m GT nsgrain-1) THEN m=nsgrain-1
     IF (mm GT nsmax-1) THEN mm=nsmax-1
     READF, 1, FORMAT = '(/)'
     READF, 1, FORMAT = '(/)'
     READF, 1, FORMAT='(19X,10(1X,A8,2X,:))', specs
     FOR l=0, tmax-1 DO BEGIN
        READF, 1, FORMAT='(6X,A11,1X,10(A11))',tim,a
;        xm[kk:mm,l,j]=DOUBLE(a[0:m-k])
     ENDFOR
     READF, 1, FORMAT = '(/)'
  ENDFOR
ENDIF

;rates of production for each molecule, destruction or production, values for gas phase, grain, and bulk, same format as normal abundances
; in output, this section prints out as "TIME EVOLUTION OF RATES"
;IF ((iplay EQ 2) OR (IPLAY EQ 3)) THEN BEGIN
;  FOR k=0,nsmax-1,10 DO BEGIN
;    m=k+9
;    IF (m GT nsmax-1) THEN m=nsmax-1
;    READF, 1, FORMAT = '(/)'
;    READF, 1, FORMAT = '(/)'
;    READF, 1, FORMAT='(19X,10(1X,A8,2X,:))', specs
;    FOR l=0, tmax-1 DO BEGIN
;      READF, 1, FORMAT='(6X,A11,1X,10(A11))',tim,a
;      xr[k:m,l,j]=DOUBLE(a[0:m-k])
;    ENDFOR
;    READF, 1, FORMAT = '(/)'
;  ENDFOR
;ENDIF

CLOSE, 1

;----------------------------------------------
;----------------------------------------------
;this section does everything above but now for multiple files
IF (ndp GT 1) THEN BEGIN
   FOR j=1,llines-1 DO BEGIN
      print, files[j]
      rname=files[j]+'op_output.d'

      OPENR, 1, rpath+rname

;     Read data from file
      tag=0
      FOR n=1,200 DO BEGIN
        IF (tag EQ 0) THEN BEGIN
          READF, 1, FORMAT = '(A2,51X,A8,2X,A12,2X,A5,1X,9A1)',dumhead,dummy1
          dummy1=STRTRIM(dummy1,2)
          IF (dummy1[0] EQ 'NT') THEN BEGIN
            tmax=FIX(dummy1[1])
            tag=1
            READF, 1, FORMAT = '(A2)',dumhead
          ENDIF
        ENDIF
      ENDFOR

      iself=0

      tmaxs[j]=tmax

      IF (idens EQ 1) OR (itemp EQ 1) OR (iself EQ 2) THEN BEGIN
        tag=0
        FOR n=1,5000 DO BEGIN
          IF (tag EQ 0) THEN BEGIN
            READF, 1, FORMAT = '(A2,1X,A5,22X,A11,3X,A11,4X,A11,4X,A9,6X,A11,6X,A8,6X,A8,6X,A11,4X,A12,4X,A12)', dummy1
            dummy1=STRTRIM(dummy1,2)
            IF (dummy1[0] EQ 'IT') THEN BEGIN
             it=FIX(dummy1[1])-1
             xnt[it,j]=DOUBLE(dummy1[2])
             temp[it,j]=DOUBLE(dummy1[3])
              dtemp[it,j]=DOUBLE(dummy1[4])
;              tau[it,j]=DOUBLE(dummy1[5])
              zeta[it,j]=DOUBLE(dummy1[6])
;              zeta[j]=DOUBLE(dummy1[6])
;              cdh2[it,j]=DOUBLE(dummy1[7])
;              cdco[it,j]=DOUBLE(dummy1[8])
;              dist[it,j]=DOUBLE(dummy1[9])
;              rx[it,j]=DOUBLE(dummy1[10])
;              rz[it,j]=DOUBLE(dummy1[11])
              IF (it EQ tmax-1) THEN tag=1
            ENDIF
          ENDIF
        ENDFOR
      ENDIF

      tag=0
      FOR n=1,100 DO BEGIN
        IF (tag EQ 0) THEN BEGIN
          READF, 1, FORMAT = '(41X,A4,9A1)', dummy1
          dummy1=STRTRIM(dummy1,2)
          IF (dummy1[0] EQ 'P')AND(nemax NE 13) THEN tag=1
          IF (dummy1[0] EQ 'D')AND(nemax EQ 13) THEN tag=1
        ENDIF
      ENDFOR
   ;   READF, 1, FORMAT = '(1X)'

      FOR k=0,nsmax-1,10 DO BEGIN
        m=k+9
        IF (m GT nsmax-1) THEN m=nsmax-1
        READF, 1, FORMAT = '(/)'
        READF, 1, FORMAT = '(/)'
        READF, 1, FORMAT='(19X,10(1X,A8,2X,:))', specs
        FOR l=0, tmax-1 DO BEGIN
          READF, 1, FORMAT='(6X,A11,1X,10(A11))',tim,a
          timval[l,j]=DOUBLE(tim)
          xn[k:m,l,j]=DOUBLE(a[0:m-k])
        ENDFOR
        READF, 1, FORMAT = '(/)'
      ENDFOR

      CLOSE, 1

   ENDFOR
ENDIF

;----------------------------------------------
; 3-phase data processing

;xnlay=FLTARR(nsmax,tmaxmax-1,ndp)
xnsum=FLTARR(nsmax,tmaxmax,ndp)
;summan=FLTARR(tmaxmax-1,ndp)
;sumdif=FLTARR(tmaxmax-1,ndp)
;summan[*]=0.d0
;sumlay=summan

fractolay=gd/tns

;FOR J=0,ndp-1 DO BEGIN
;  FOR I=1,tmaxs(J)-1 DO BEGIN
;    xnlay[*,I-1,J]=xn[*,I,J]-xn[*,I-1,J]
;    sumdif[I-1,J]=TOTAL(xnlay[nsgas+nsgrain:nsmax-1,I-1,J])
;    sumlay[I-1,J]=sumlay[I-1,J]+TOTAL(xn[nsgas:nsgas+nsgrain-1,I,J])*fractolay
;    summan[I-1,J]=summan[I-1,J]+TOTAL(xn[nsgas+nsgrain:nsmax-1,I,J])*fractolay
;  ENDFOR
;ENDFOR
;
;summansur=summan
;FOR J=0,ndp-1 DO BEGIN
;  FOR I=1,tmaxs(J)-1 DO BEGIN
;    summansur[I-1,J]=summansur[I-1,J]+TOTAL(xn[nsgas:nsgas+nsgrain-1,I,J])*fractolay
;  ENDFOR
;ENDFOR

; this section makes it so that if the plotting routine calls on xnsum and the value is gas, it will print out gas phase only, if the value is grain or mantle it will print out the sum of both values
FOR J=0,ndp-1 DO BEGIN
  FOR I=0,nsgas-1 DO BEGIN
    xnsum[I,*,J]=xn[I,*,J]
  ENDFOR
  FOR I=nsgas,nsgas+nsgrain-1 DO BEGIN
    xnsum[I,*,J]=xn[I,*,J]+xn[I+nsgrain,*,J]
  ENDFOR
  FOR I=nsgas+nsgrain,nsmax-1 DO BEGIN
    xnsum[I,*,J]=xn[I,*,J]+xn[I-nsgrain,*,J]
  ENDFOR
ENDFOR    

;FOR J=0,ndp-1 DO BEGIN
;  FOR I=1,tmaxs(J)-1 DO BEGIN
;    xnlay[*,I-1,J]=xnlay[*,I-1,J]/sumdif[I-1,J]
;  ENDFOR
;ENDFOR
;
;;iplay=0
;IF (iplay EQ 0) THEN BEGIN
;  FOR J=0,ndp-1 DO BEGIN
;    xm[*,J,0]=xnlay[*,J,0]
;    FOR I=1,tmaxs(J)-1 DO BEGIN
;      xm[*,I,J]=xnlay[*,I-1,J]
;    ENDFOR
;  ENDFOR
;ENDIF
;
;FOR J=0,ndp-1 DO BEGIN
;  FOR I=1,tmaxs[J]-1 DO BEGIN
;    FOR K=0,nsmax-1 DO BEGIN
;      IF (xm[K,I-1,J] LT 1.d-50) THEN xm[K,I-1,J]=1.d-50
;    ENDFOR
;  ENDFOR
;ENDFOR

;----------------------------------------------
;this section renames for plotting, does subscripts and superscripts for numbers, most likely will just find a way to do this on my own in python
name = STRTRIM(name,2)
;Set up/down position of numbers in spec names:
pname=name
pname[*]=''
name8=STRARR(8)
numar=['0','1','2','3','4','5','6','7','8','9','+']
FOR i=0,nsmax-1 DO BEGIN
;   IF (name[i] EQ 'JCH2OH') THEN name[i]='JCH3O'
   FOR k=0,7 DO BEGIN
      name8[k]=STRMID(name[i],k,1)
      str1=''
      IF (name8[k] NE '') THEN str1='!N'+name8[k]
      FOR j=0,10 DO BEGIN
         IF (name8[k] EQ numar[j]) THEN BEGIN
            IF (j LT 10) THEN str1='!D'+name8[k]
            IF (j EQ 10) THEN str1='!U'+name8[k]
         ENDIF
      ENDFOR
   pname[i]=pname[i]+str1
   ENDFOR
   IF (name[i] EQ 'E') THEN pname[i]='e!U-'
   pname[i]=pname[i]+'!N'
   IF (STRMID(name[i],0,1) EQ 'J') THEN pname[i]=STRMID(pname[i],3)+' (s)'
;   IF (STRMID(name[i],0,1) EQ '#') THEN pname[i]=STRMID(pname[i],3)+' (m)'
   IF (STRMID(name[i],0,1) EQ '#') THEN pname[i]=STRMID(pname[i],3)
   
ENDFOR


;-----------------------------------------
;-----------------------------------------
; Crude plotting routines for you to play with:

;spn=299
;
;n=3
;plot, timval[0:tmaxs[n]-1,n],xn[spn,0:tmaxs[n]-1,n],/xlog,/ylog,$
;  xrange=[timval[1,n],timval[tmaxs[n]-1,n]],yrange=[1.d-15,1.d-6],$
;  xstyle=1,ystyle=1,xtitle='t (yr)',ytitle='n(i)/n!DH!N',charsize=1.5
;
;xyouts, 2.d+3,1.d-7,pname[spn],charsize=2.
;
;n=2
;oplot, timval[0:tmaxs[n]-1,n],xn[spn,0:tmaxs[n]-1,n], linestyle=5
;n=1
;oplot, timval[0:tmaxs[n]-1,n],xn[spn,0:tmaxs[n]-1,n], linestyle=2
;n=0
;oplot, timval[0:tmaxs[n]-1,n],xn[spn,0:tmaxs[n]-1,n], linestyle=1



; Or try this to plot against gas temperature, for example (uncomment)
;plot, temp[0:tmaxs[n]-1,n],xn[spn,0:tmaxs[n]-1,n],/xlog,/ylog,xrange=[temp[0,n],temp[tmaxs[n]-1,n]],yrange=[1.d-15,1.d-6],xstyle=1,ystyle=1


;-----------------------------------------
;-----------------------------------------

delvar, a,i,j,k,kk,l,m,mm,specs,tim,str1, $
        dummy1,tag,idens,itemp,it,name8,numar,  $
cdco,cdh2,dist,fractolay,iself,sumdif,summansur,xnlay

END
