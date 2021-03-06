
!==============================================================================|
   SUBROUTINE PRINT_VALS          

!------------------------------------------------------------------------------|

   USE ALL_VARS
   USE MOD_OBCS
#  if defined (MULTIPROCESSOR)
   USE MOD_PAR
#  endif
#  if defined (NG_OI_ASSIM)
   USE MOD_ASSIM
#  endif
   IMPLICIT NONE
   INTEGER :: I,K,IOUTTMP,ierr
   REAL(SP), ALLOCATABLE, DIMENSION(:,:) :: UTMP,VTMP
   REAL(SP), ALLOCATABLE, DIMENSION(:)   :: UATMP,VATMP
   REAL(SP), ALLOCATABLE, DIMENSION(:,:)   :: T1TMP,S1TMP
   REAL(SP), ALLOCATABLE, DIMENSION(:)   :: ELTMP,DTMP

!==============================================================================|
   

    IF(SERIAL)THEN

# if defined (TIDE_OUTPUT)
      if(iint >= TIDE_INITIAL .and. mod(iint, TIDE_INTERVAL)==0) then
         write(911,'(300f8.4)')    (EL(I_OBC_GL(I)),I=1,IOBCN_GL)
         write(912,'(I7,300f8.4)') iint,(EL(I_OBCNODE_GL(I)),I=1,IOBCNODE_GL)
         write(913,'(I7,300f8.4)') iint,(UA(I_OBCELL_GL(I)),I=1,IOBCELL_GL)
         write(913,'(I7,300f8.4)') iint,(VA(I_OBCELL_GL(I)),I=1,IOBCELL_GL)
         do K = 1,kbm1
            write(913,'(I7,300f8.4)') iint,(U(I_OBCELL_GL(I),k),I=1,IOBCELL_GL)
            write(913,'(I7,300f8.4)') iint,(V(I_OBCELL_GL(I),k),I=1,IOBCELL_GL)
         end do
      end if

      if(iint == TIDE_INITIAL) then
         do I = 1,NNodeGL
            write(914,*) EL(I)
         end do
         do I = 1,MElemGL
            write(915,'(300f8.4)') (U(I,K),V(I,K),K=1,kbm1)
         end do
         write(916,*) IOBCNODE_GL
         do I = 1,IOBCNODE_GL
            write(916,*) I_OBCNODE_GL(I)
         enddo
         write(917,*) IOBCELL_GL
         do I = 1,IOBCELL_GL
            write(917,*) I_OBCELL_GL(I)
         enddo
      end if
# endif

    END IF

#  if defined (MULTIPROCESSOR)
    IF(PAR)THEN
     ALLOCATE(UTMP(MElemGL,KB))
     ALLOCATE(VTMP(MElemGL,KB))
     ALLOCATE(T1TMP(NNodeGL,KB))
     ALLOCATE(S1TMP(NNodeGL,KB))
     ALLOCATE(ELTMP(NNodeGL))
     ALLOCATE(DTMP(NNodeGL))
     CALL MPI_BARRIER(MPI_COMM_WORLD,IERR)
     ALLOCATE(UATMP(MElemGL),VATMP(MElemGL))
     CALL GATHER(LBOUND(U,1),  UBOUND(U,1),  MElem,MElemGL,KB,MYID,NPROCS,EMAP,U,  UTMP)
     CALL GATHER(LBOUND(V,1),  UBOUND(V,1),  MElem,MElemGL,KB,MYID,NPROCS,EMAP,V,  VTMP)
     CALL GATHER(LBOUND(UA,1), UBOUND(UA,1), MElem,MElemGL, 1,MYID,NPROCS,EMAP,UA, UATMP)
     CALL GATHER(LBOUND(VA,1), UBOUND(VA,1), MElem,MElemGL, 1,MYID,NPROCS,EMAP,VA, VATMP)
!     CALL GATHER(LBOUND(T1,1),  UBOUND(T1,1),  NNode,NNodeGL,KB,MYID,NPROCS,NMAP,T1,  T1TMP)
!     CALL GATHER(LBOUND(S1,1),  UBOUND(S1,1),  NNode,NNodeGL,KB,MYID,NPROCS,NMAP,S1,  S1TMP)
     CALL GATHER(LBOUND(EL,1), UBOUND(EL,1), NNode,NNodeGL, 1,MYID,NPROCS,NMAP,EL, ELTMP)

# if defined (TIDE_OUTPUT)
      if(msr .and. iint >= TIDE_INITIAL .and. mod(iint, TIDE_INTERVAL)==0) then
         write(911,'(300f8.4)')    (ELTMP(I_OBC_GL(I)),I=1,IOBCN_GL)              !node
         write(912,'(I7,300f8.4)') iint,(ELTMP(I_OBCNODE_GL(I)),I=1,IOBCNODE_GL)  !elevation
         write(913,'(I7,300f8.4)') iint,(UATMP(I_OBCELL_GL(I)),I=1,IOBCELL_GL)    !velocity u
         write(913,'(I7,300f8.4)') iint,(VATMP(I_OBCELL_GL(I)),I=1,IOBCELL_GL)    !velocity v
         do K = 1,kbm1
            write(913,'(I7,300f8.4)') iint,(UTMP(I_OBCELL_GL(I),k),I=1,IOBCELL_GL)
            write(913,'(I7,300f8.4)') iint,(VTMP(I_OBCELL_GL(I),k),I=1,IOBCELL_GL)
         end do
      end if

      if(msr .and. iint == TIDE_INITIAL) then
         do I = 1,NNodeGL
            write(914,*) ELTMP(I)                                    !elevation
         end do
         do I = 1,MElemGL
            write(915,'(300f8.4)') (UTMP(I,K),VTMP(I,K),K=1,kbm1)    !u,v
         end do
         write(916,*) IOBCNODE_GL
         do I = 1,IOBCNODE_GL
            write(916,*) I_OBCNODE_GL(I)                             !node
         enddo
         write(917,*) IOBCELL_GL
         do I = 1,IOBCELL_GL
            write(917,*) I_OBCELL_GL(I)                              !cell
         enddo
      end if
# endif
   
      DEALLOCATE(T1TMP,S1TMP,ELTMP,DTMP)
      DEALLOCATE(UTMP,VTMP,UATMP)   !Wen Long also deallocated these three arrays

   END IF
#  endif
 
    END
