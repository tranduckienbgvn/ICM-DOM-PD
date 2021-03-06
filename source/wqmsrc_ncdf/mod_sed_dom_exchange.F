MODULE MOD_SED_DOM_EXCHANGE

! this module is used to pass variables between mod_sed_dom,mod_wqm, and mod_sed

!It makes them all independent of eachother so that one can be run without the other.

!B Clark June 15, 2015

    USE MOD_LIMS, ONLY: MTLOC
    USE MOD_SIZES, ONLY: MGL
    USE MOD_PREC, ONLY: SP
  
 IMPLICIT NONE
 SAVE
 
LOGICAL :: SED_DOM_FLAG = .TRUE.
LOGICAL  :: PERCOLATION_FLAG = .TRUE.
 REAL(SP),ALLOCATABLE ::            JDOCX_SHARE1(:),    &  !Diagenesis DOC flux  (mg C/m^2)
									JDOCX_SHARE2(:),    &  !Diagenesis DOC flux  (mg C/m^2)
								     JDONX_SHARE1(:),    &  !Diagenesis DON flux layer 1
								     JDONX_SHARE2(:),    &  !Diagenesis DON flux layer 22									 
								     JDOPX_SHARE1(:)  ,&      !Diagenesis DOP flux
									 JDOPX_SHARE2(:)        !Diagenesis DOP flux

 REAL(SP),ALLOCATABLE ::            JNH4_GL_SHARE(:),    &  !NH4 flux in sediments (mg N / m^2/day)
                                    JNO3_GL_SHARE(:),    &  !NO3 flux in sediments (mg N / m^2/day)
                                    NO31_GL_SHARE(:),&        !sediment layer 1 NO3 conc
                                    NO32_GL_SHARE(:),&        !sediment layer 2 NO3 conc
                                    NH41_GL_SHARE(:),&        !sediment layer 1 NH4 conc
                                    NH42_GL_SHARE(:)       !sediment layer 2 NH4 conc
REAL(SP), ALLOCATABLE :: SED_TEMP_SHARE(:),  &
						 ZSED_SHARE(:),    &
						 W2_SHARE(:),  &
						 HSED1_SHARE(:)

REAL(SP)			::	 DLTS_SHARE

REAL(SP), ALLOCATABLE :: S_SHARE(:), KL12_SHARE(:) ! diffusion velocity (m/d) for sediment porewater


! obsolete
!REAL(SP),ALLOCATABLE ::  J_LDOC_SHARE(:),        &    !LABILE DOC FROM WATER QUALITY MODEL
!						 J_RDOC_SHARE(:),        &    !REFRACTORY DOC FROM WATER QUALITY MODEL
!						 J_LDON_SHARE(:),        &    !LABILE DON 
!						 J_RDON_SHARE(:),        &    !REFRACTORY DON
!						 J_LDOP_SHARE(:),        &    !LABILE DOP
!						 J_RDOP_SHARE(:)				 !REFRACTORY DOP

REAL(SP), DIMENSION(:), ALLOCATABLE :: JWCDOC1, JWCDOC2, JWCDOC3, &
									   JWNCDOC1, JWNCDOC2, JWNCDOC3, &
				                       JWCDON1, JWCDON2, JWCDON3, &
									   JWNCDON1, JWNCDON2, JWNCDON3, &
									   JWCDOP1, JWCDOP2, JWCDOP3, &
									   JWNCDOP1, JWNCDOP2, JWNCDOP3
									   
REAL(SP), ALLOCATABLE, DIMENSION(:)::  	FX_POC1TM1,  &   !  Added by B Clark Nov 2015 for hydrolysis of POC to DOC
	                        	FX_POC2TM1,   &
	                         	FX_POC3TM1,  &
	                        	FX_PON1TM1,  &
	                          	FX_PON2TM1,   &
		                        FX_PON3TM1,    &	
		                        FX_POP1TM1,  &
		                        FX_POP2TM1,   &
	                        	FX_POP3TM1					
CONTAINS

    SUBROUTINE SED_DOM_SHARE_ALLOCATE
 
		 ALLOCATE(JDOCX_SHARE1(MTLOC));    JDOCX_SHARE1=0.0
		  ALLOCATE(JDOCX_SHARE2(MTLOC));    JDOCX_SHARE2=0.0
	     ALLOCATE(JDONX_SHARE1(MTLOC));    JDONX_SHARE1=0.0
	     ALLOCATE(JDONX_SHARE2(MTLOC));    JDONX_SHARE2=0.0
	     ALLOCATE(JDOPX_SHARE1(MTLOC));    JDOPX_SHARE1=0.0
	     ALLOCATE(JDOPX_SHARE2(MTLOC));    JDOPX_SHARE2=0.0
		 ALLOCATE(SED_TEMP_SHARE(MTLOC)); SED_TEMP_SHARE=0.0
		 ALLOCATE(ZSED_SHARE(MTLOC));     ZSED_SHARE=0.0
		 ALLOCATE(W2_SHARE(MTLOC));       W2_SHARE=0.0
		 ALLOCATE(HSED1_SHARE(MTLOC));      HSED1_SHARE=0.0
		 ALLOCATE(S_SHARE(MTLOC)); S_SHARE=0.0
		 ALLOCATE(KL12_SHARE(MTLOC)); KL12_SHARE=0.0;
		 
		!ALLOCATE(J_LDOC_SHARE(1:MTLOC));  J_LDOC_SHARE=0.0           
		!ALLOCATE(J_RDOC_SHARE(1:MTLOC));  J_RDOC_SHARE=0.0          
		!ALLOCATE(J_LDON_SHARE(1:MTLOC));  J_LDON_SHARE=0.0           
		!ALLOCATE(J_RDON_SHARE(1:MTLOC));  J_RDON_SHARE=0.0           
		!ALLOCATE(J_LDOP_SHARE(1:MTLOC));  J_LDOP_SHARE=0.0          
		!ALLOCATE(J_RDOP_SHARE(1:MTLOC));  J_RDOP_SHARE=0.0	

        ALLOCATE(JNH4_GL_SHARE(MGL)) ;JNH4_GL_SHARE=0.0     !NH4 flux in sediments (mg N / m^2/day)
        ALLOCATE(JNO3_GL_SHARE(MGL))  ; JNO3_GL_SHARE = 0.0 !NO3 flux in sediments (mg N / m^2/day)
        ALLOCATE(NO31_GL_SHARE(MGL)) ; NO31_GL_SHARE=0.0     !sediment layer 1 NO3 conc
        ALLOCATE(NO32_GL_SHARE(MGL)) ;  NO32_GL_SHARE = 0.0      !sediment layer 2 NO3 conc
        ALLOCATE(NH41_GL_SHARE(MGL)) ;  NH41_GL_SHARE = 0.0     !sediment layer 1 NH4 conc
        ALLOCATE(NH42_GL_SHARE(MGL)) ; NH42_GL_SHARE = 0.0

		 ALLOCATE(JWCDOC1(MTLOC)); JWCDOC1 = 0.0
		 ALLOCATE(JWCDOC2(MTLOC)); JWCDOC2 = 0.0
		 ALLOCATE(JWCDOC3(MTLOC)); JWCDOC3 = 0.0
		 ALLOCATE(JWNCDOC1(MTLOC)); JWNCDOC1 = 0.0
		 ALLOCATE(JWNCDOC2(MTLOC)); JWNCDOC2 = 0.0
		 ALLOCATE(JWNCDOC3(MTLOC)); JWNCDOC3 = 0.0

		 ALLOCATE(JWCDON1(MTLOC)); JWCDON1 = 0.0
		 ALLOCATE(JWCDON2(MTLOC)); JWCDON2 = 0.0
		 ALLOCATE(JWCDON3(MTLOC)); JWCDON3 = 0.0
		 ALLOCATE(JWNCDON1(MTLOC)); JWNCDON1 = 0.0
		 ALLOCATE(JWNCDON2(MTLOC)); JWNCDON2 = 0.0
		 ALLOCATE(JWNCDON3(MTLOC)); JWNCDON3 = 0.0
		 
		 ALLOCATE(JWCDOP1(MTLOC)); JWCDOP1 = 0.0
		 ALLOCATE(JWCDOP2(MTLOC)); JWCDOP2 = 0.0
		 ALLOCATE(JWCDOP3(MTLOC)); JWCDOP3 = 0.0
		 ALLOCATE(JWNCDOP1(MTLOC)); JWNCDOP1 = 0.0
		 ALLOCATE(JWNCDOP2(MTLOC)); JWNCDOP2 = 0.0
		 ALLOCATE(JWNCDOP3(MTLOC)); JWNCDOP3 = 0.0
		 
		ALLOCATE(FX_POC1TM1(MTLOC));   FX_POC1TM1 = 0.0
		ALLOCATE(FX_POC2TM1(MTLOC));   FX_POC2TM1 = 0.0
		ALLOCATE(FX_POC3TM1(MTLOC));   FX_POC3TM1 = 0.0

		ALLOCATE(FX_PON1TM1(MTLOC));   FX_PON1TM1 = 0.0
		ALLOCATE(FX_PON2TM1(MTLOC));   FX_PON2TM1 = 0.0
		ALLOCATE(FX_PON3TM1(MTLOC));   FX_PON3TM1 = 0.0
		
		ALLOCATE(FX_POP1TM1(MTLOC));   FX_POP1TM1 = 0.0
		ALLOCATE(FX_POP2TM1(MTLOC));   FX_POP2TM1 = 0.0
		ALLOCATE(FX_POP3TM1(MTLOC));   FX_POP3TM1 = 0.0
		 
    END SUBROUTINE SED_DOM_SHARE_ALLOCATE
	
	SUBROUTINE SED_DOM_SHARE_DEALLOCATE

		 IF(ALLOCATED(JDOCX_SHARE1)) DEALLOCATE(JDOCX_SHARE1)
		 IF(ALLOCATED(JDOCX_SHARE2)) DEALLOCATE(JDOCX_SHARE2)
		 IF(ALLOCATED(JDONX_SHARE1)) DEALLOCATE(JDONX_SHARE1)
		 IF(ALLOCATED(JDONX_SHARE2)) DEALLOCATE(JDONX_SHARE2)
		 IF(ALLOCATED(JDOPX_SHARE1)) DEALLOCATE(JDOPX_SHARE1)
		 		 IF(ALLOCATED(JDOPX_SHARE2)) DEALLOCATE(JDOPX_SHARE2)
		 IF(ALLOCATED(SED_TEMP_SHARE)) DEALLOCATE(SED_TEMP_SHARE)
		 IF(ALLOCATED(ZSED_SHARE)) DEALLOCATE(ZSED_SHARE)
		 IF(ALLOCATED(W2_SHARE)) DEALLOCATE(W2_SHARE)
		 IF(ALLOCATED(HSED1_SHARE)) DEALLOCATE(HSED1_SHARE) 
		 IF(ALLOCATED(S_SHARE)) DEALLOCATE(S_SHARE)
		 IF(ALLOCATED(KL12_SHARE)) DEALLOCATE(KL12_SHARE)
		 !IF(ALLOCATED(J_LDOC_SHARE)) DEALLOCATE(J_LDOC_SHARE)
		 !IF(ALLOCATED(J_RDOC_SHARE)) DEALLOCATE(J_RDOC_SHARE)
		 !IF(ALLOCATED(J_LDON_SHARE)) DEALLOCATE(J_LDON_SHARE)
		 !IF(ALLOCATED(J_RDON_SHARE)) DEALLOCATE(J_RDON_SHARE)
		 !IF(ALLOCATED(J_LDOP_SHARE)) DEALLOCATE(J_LDOP_SHARE)
		 !IF(ALLOCATED(J_RDOP_SHARE)) DEALLOCATE(J_RDOP_SHARE)


       IF(ALLOCATED(JNH4_GL_SHARE)) DEALLOCATE(JNH4_GL_SHARE)    !NH4 flux in sediments (mg N / m^2/day)
        IF(ALLOCATED(JNO3_GL_SHARE))   DEALLOCATE(JNO3_GL_SHARE)  !NO3 flux in sediments (mg N / m^2/day)
        IF(ALLOCATED(NO31_GL_SHARE))   DEALLOCATE(NO31_GL_SHARE)   !sediment layer 1 NO3 conc
        IF(ALLOCATED(NO32_GL_SHARE))   DEALLOCATE(NO32_GL_SHARE)     !sediment layer 2 NO3 conc
        IF(ALLOCATED(NH41_GL_SHARE))   DEALLOCATE(NH41_GL_SHARE)      !sediment layer 1 NH4 conc
        IF(ALLOCATED(NH42_GL_SHARE))  DEALLOCATE(NH42_GL_SHARE)

		 IF(ALLOCATED(JWCDOC1)) DEALLOCATE(JWCDOC1)
		 IF(ALLOCATED(JWCDOC2)) DEALLOCATE(JWCDOC2)
		 IF(ALLOCATED(JWCDOC3)) DEALLOCATE(JWCDOC3)
		 IF(ALLOCATED(JWNCDOC1)) DEALLOCATE(JWNCDOC1)
		 IF(ALLOCATED(JWNCDOC2)) DEALLOCATE(JWNCDOC2)
		 IF(ALLOCATED(JWNCDOC3)) DEALLOCATE(JWNCDOC3)

		 IF(ALLOCATED(JWCDON1)) DEALLOCATE(JWCDON1)
		 IF(ALLOCATED(JWCDON2)) DEALLOCATE(JWCDON2)
		 IF(ALLOCATED(JWCDON3)) DEALLOCATE(JWCDON3)
		 IF(ALLOCATED(JWNCDON1)) DEALLOCATE(JWNCDON1)
		 IF(ALLOCATED(JWNCDON2)) DEALLOCATE(JWNCDON2)
		 IF(ALLOCATED(JWNCDON3)) DEALLOCATE(JWNCDON3)

		 IF(ALLOCATED(JWCDON1)) DEALLOCATE(JWCDOP1)
		 IF(ALLOCATED(JWCDON2)) DEALLOCATE(JWCDOP2)
		 IF(ALLOCATED(JWCDON3)) DEALLOCATE(JWCDOP3)
		 IF(ALLOCATED(JWNCDON1)) DEALLOCATE(JWNCDOP1)
		 IF(ALLOCATED(JWNCDON2)) DEALLOCATE(JWNCDOP2)
		 IF(ALLOCATED(JWNCDON3)) DEALLOCATE(JWNCDOP3)
		 
		 IF(ALLOCATED(FX_POC1TM1)) DEALLOCATE(FX_POC1TM1)
		 IF(ALLOCATED(FX_POC1TM1)) DEALLOCATE(FX_POC1TM1)
		 IF(ALLOCATED(FX_POC1TM1)) DEALLOCATE(FX_POC1TM1)
		 IF(ALLOCATED(FX_PON1TM1)) DEALLOCATE(FX_PON1TM1)
		 IF(ALLOCATED(FX_PON1TM1)) DEALLOCATE(FX_PON1TM1)
		 IF(ALLOCATED(FX_PON1TM1)) DEALLOCATE(FX_PON1TM1)
		 IF(ALLOCATED(FX_POP1TM1)) DEALLOCATE(FX_POP1TM1)
		 IF(ALLOCATED(FX_POP1TM1)) DEALLOCATE(FX_POP1TM1)
		 IF(ALLOCATED(FX_POP1TM1)) DEALLOCATE(FX_POP1TM1)
		 
    END SUBROUTINE SED_DOM_SHARE_DEALLOCATE

 END MODULE MOD_SED_DOM_EXCHANGE
 
