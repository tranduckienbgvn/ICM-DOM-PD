!==============================================================================|
!     this subroutine is used to calculate the true temperature                !
!     and salinity by including vertical diffusion implicitly.                 !
!==============================================================================|
!     See NOTES in VDIF_TS.F about possible optimization!

   SUBROUTINE VDIF_TS_GOM(NCON1,F)                

!------------------------------------------------------------------------------|

   USE ALL_VARS
   USE BCS
#  if defined (WET_DRY)
   USE MOD_WD
#  endif
   IMPLICIT NONE
   INTEGER :: I,K,NCON1,J,KI,hutemp
!   REAL(SP) :: TMP,TMP1,TMP2,TMP3,QTMP,GW,ZDEP,FKH,UMOLPR,WETFAC
!   REAL(SP), DIMENSION(0:NTNode,KB)  :: F
!   REAL(SP), DIMENSION(NNode,KB)     :: FF,AF,CF,VHF,VHPF,RAD
!   REAL(SP), DIMENSION(NNode)        :: KHBOTTOM,WFSURF,SWRADF
   REAL(DP) :: TMP,TMP1,TMP2,TMP3,QTMP,GW,ZDEP,FKH,UMOLPR,WETFAC
   REAL(SP), DIMENSION(0:NTNode,KB)  :: F
   REAL(DP), DIMENSION(NNode,KB)     :: FF,AF,CF,VHF,VHPF,RAD
   REAL(DP), DIMENSION(NNode)        :: KHBOTTOM,WFSURF,SWRADF,SASURF
   REAL(DP), DIMENSION(NNode)        :: COSGAMA1,COSGAMA2


   UMOLPR = UMOL*1.E0_SP
   SASURF = 0.0_SP
!
!------------------------------------------------------------------------------!
!                                                                              !
!        the following section solves the equation                             !
!         dti*(kh*f')'-f=-fb                                                   !
!                                                                              !
!------------------------------------------------------------------------------!


   DO K = 2, KBM1
     DO I = 1, NNode
#  if !defined (WET_DRY)
       IF (D(I) > 0.0_SP) THEN
#  else
       IF(ISWET_NODE_CURRENTSTEP(I) == 1)THEN
#  endif
         FKH = KH(I,K)

         IF(K == KBM1) THEN
           KHBOTTOM(I)=FKH
         END IF

         AF(I,K-1)=-DTI*(FKH+UMOLPR)/(DZ(I,K-1)*DZZ(I,K-1)*D(I)*D(I))
         CF(I,K)=-DTI*(FKH+UMOLPR)/(DZ(I,K)*DZZ(I,K-1)*D(I)*D(I))
       END IF
     END DO
   END DO


!------------------------------------------------------------------------------!
!     the net heat flux input.                                                 !
!     the method shown below can be used when we turn off the                  !
!     body force in subroutine advt. be sure this method could                 !
!     cause the surface overheated if the vertical resolution                  !
!     is not high enough.                                                      !
!------------------------------------------------------------------------------!

   IF(NCON1 == 1) THEN
       
   IF(H_TYPE == 'flux_h')THEN
!     DO I=1,NNode
!       WFSURF(I)=WTSURF(I)
!       SWRADF(I)=SWRAD(I)
!     END DO
       WFSURF(1:NNode)=WTSURF(1:NNode)
       SWRADF(1:NNode)=SWRAD(1:NNode)
      

     DO K = 1, KB
       DO I = 1, NNode
#    if !defined (WET_DRY)
       IF(D(I) > 0.0_SP) THEN
#    else
       IF(ISWET_NODE_CURRENTSTEP(I) == 1)THEN
#    endif
         ZDEP = Z(I,K)*D(I)

!       SPECIFIED PARAMETER FOR GOM CASE (JUNE 18, 2003)
         IF(D(I) < 100.0_SP) THEN
           RHEAT=0.78_SP
           ZETA1=1.4_SP
           ZETA2=6.3_SP
         ELSE IF(D(I) > 150.0_SP) THEN
           RHEAT=0.58_SP
           ZETA1=0.35_SP
           ZETA2=23.0_SP
         ELSE
           TMP1=(D(I)-100.0_SP)/(150.0_SP-100.0_SP)
           RHEAT=0.78_SP+(0.58_SP-0.78_SP)*TMP1
           ZETA1=1.4_SP+ (0.35_SP-1.4_SP )*TMP1
           ZETA2=6.3_SP+ (23.0_SP-6.3_SP )*TMP1
         END IF

         RAD(I,K)=SWRADF(I)*(RHEAT*EXP(ZDEP/ZETA1)+(1-RHEAT)*EXP(ZDEP/ZETA2))
       END IF
       END DO
     END DO

   ELSE !! H_TYPE = 'body_h'   
     RAD    = 0.0_SP
     WFSURF = 0.0_SP
     SWRADF = 0.0_SP
   END IF 
        
   ELSE IF(NCON1 == 2) THEN

     DO I = 1, NNode
       SWRADF(I)= 0.0_SP
       WFSURF(I)=0.0_SP
       COSGAMA1(I)=1.0_SP
!       SASURF(I)=-(QEVAP3(I)-QPREC3(I))*F(I,1)*ROFVROS*COSGAMA1(I)
!---Considering the salinity conservation, the sea surface salinity flux-----!
!---can be set as zero, that is----------------------------------------------!
       SASURF(I) = 0.0_SP
!----------------------------------------------------------------------------!
       DO K=1,KB
         RAD(I,K)=0.0_SP
       END DO
     END DO

   ELSE
     PRINT*,'NCON NOT CORRECT IN VDIF_TS',NCON1
     CALL PSTOP
   END IF

!------------------------------------------------------------------------------!
!   surface bcs; wfsurf                                                        !
!------------------------------------------------------------------------------!

   DO I = 1, NNode
#  if !defined (WET_DRY)
     IF (D(I) > 0.0_SP) THEN
#  else
     IF(ISWET_NODE_CURRENTSTEP(I) == 1)THEN
#  endif
       VHF(I,1) = AF(I,1) / (AF(I,1)-1.)
       VHPF(I,1) = -DTI *(SASURF(I)+WFSURF(I)-SWRADF(I) &
                   +RAD(I,1)-RAD(I,2)) / (-DZ(I,1)*D(I)) - F(I,1)
        VHPF(I,1) = VHPF(I,1) / (AF(I,1)-1.)
        END IF
   END DO

   DO K = 2, KBM2
     DO I = 1, NNode
#  if !defined (WET_DRY)
     IF (D(I) > 0.0_SP) THEN
#  else
     IF(ISWET_NODE_CURRENTSTEP(I) == 1)THEN
#  endif
         VHPF(I,K)=1./ (AF(I,K)+CF(I,K)*(1.-VHF(I,K-1))-1.)
         VHF(I,K) = AF(I,K) * VHPF(I,K)
         VHPF(I,K) = (CF(I,K)*VHPF(I,K-1)-DBLE(F(I,K)) &
                     +DTI*(RAD(I,K)-RAD(I,K+1))/(D(I)*DZ(I,K)))*VHPF(I,K)
        END IF
     END DO
   END DO


   DO  K = 1, KBM1
     DO  I = 1, NNode
#  if !defined (WET_DRY)
     IF (D(I) > 0.0_SP) THEN
#  else
     IF(ISWET_NODE_CURRENTSTEP(I) == 1)THEN
#  endif
         FF(I,K) = F(I,K)
       END IF
     END DO
   END DO

   DO I = 1, NNode
#  if !defined (WET_DRY)
     IF (D(I) > 0.0_SP .AND.ISONB(I) /= 2) THEN
#  else
     IF(ISWET_NODE_CURRENTSTEP(I) == 1 .AND.ISONB(I) /= 2)THEN
#  endif
       TMP1=PFPXB(I)*COS(SITA_GD(I))+PFPYB(I)*SIN(SITA_GD(I))
       TMP2=AH_BOTTOM(I)*PHPN(I)
       TMP3=KHBOTTOM(I)+UMOLPR+AH_BOTTOM(I)*PHPN(I)*PHPN(I)
       TMP=TMP1*TMP2/TMP3*(KHBOTTOM(I)+UMOLPR)

!----------------------------------------------------------------------
       IF (TMP1 > 0.0_SP) TMP=0.0_SP
!       !also try TMP = 0.0_SP
!----------------------------------------------------------------------

       GW=0.0_SP
       IF(IBFW > 0) THEN
         DO J=1,IBFW
           IF(I == NODE_BFW(J).AND.(NCON1 == 2)) THEN
             QTMP=-(F(I,KBM1)*D(I)*DZ(I,KBM1)*BFWDIS(J))/ &
                   (D(I)*DZ(I,KBM1)*ART1(I)+BFWDIS(J))
             GW=DTI/D(I)/DZ(I,KBM1)*QTMP
             TMP=0.0_SP
           END IF
         END DO
       END IF
       
       FF(I,KBM1) = ((CF(I,KBM1)*VHPF(I,KBM2)-FF(I,KBM1)-GW &
               +DTI*(RAD(I,KBM1)-RAD(I,KB)-TMP)/(D(I)*DZ(I,KBM1))) &
                /(CF(I,KBM1)*(1.-VHF(I,KBM2))-1._SP))
     END IF
   END DO

   DO  K = 2, KBM1
     KI = KB - K
     DO  I = 1, NNode
#  if !defined (WET_DRY)
     IF (D(I) > 0.0_SP .AND.ISONB(I) /= 2) THEN
#  else
     IF(ISWET_NODE_CURRENTSTEP(I) == 1 .AND.ISONB(I) /= 2)THEN
#  endif
         FF(I,KI) = (VHF(I,KI)*FF(I,KI+1)+VHPF(I,KI))
       END IF
     END DO
   END DO

   DO I = 1, NNode
#  if defined (WET_DRY)
     IF(ISWET_NODE_CURRENTSTEP(I)*ISWET_NODE_LASTSTEP(I) == 1 )then
#  endif
       DO K = 1, KBM1
         F(I,K) = FF(I,K)
       END DO
#  if defined (WET_DRY)
     END IF
#  endif
   END DO

   RETURN
   END SUBROUTINE VDIF_TS_GOM
!==============================================================================|
