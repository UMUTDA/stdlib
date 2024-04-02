module stdlib_linalg_blas_s
     use stdlib_linalg_constants
     use stdlib_linalg_blas_aux
     implicit none(type,external)
     private


     public :: sp,dp,qp,lk,ilp
     public :: stdlib_sasum
     public :: stdlib_saxpy
     public :: stdlib_scasum
     public :: stdlib_scnrm2
     public :: stdlib_scopy
     public :: stdlib_sdot
     public :: stdlib_sdsdot
     public :: stdlib_sgbmv
     public :: stdlib_sgemm
     public :: stdlib_sgemv
     public :: stdlib_sger
     public :: stdlib_snrm2
     public :: stdlib_srot
     public :: stdlib_srotg
     public :: stdlib_srotm
     public :: stdlib_srotmg
     public :: stdlib_ssbmv
     public :: stdlib_sscal
     public :: stdlib_sspmv
     public :: stdlib_sspr
     public :: stdlib_sspr2
     public :: stdlib_sswap
     public :: stdlib_ssymm
     public :: stdlib_ssymv
     public :: stdlib_ssyr
     public :: stdlib_ssyr2
     public :: stdlib_ssyr2k
     public :: stdlib_ssyrk
     public :: stdlib_stbmv
     public :: stdlib_stbsv
     public :: stdlib_stpmv
     public :: stdlib_stpsv
     public :: stdlib_strmm
     public :: stdlib_strmv
     public :: stdlib_strsm
     public :: stdlib_strsv

     ! 32-bit real constants 
     real(sp),    parameter, private ::     negone = -1.00_sp
     real(sp),    parameter, private ::       zero = 0.00_sp
     real(sp),    parameter, private ::       half = 0.50_sp
     real(sp),    parameter, private ::        one = 1.00_sp
     real(sp),    parameter, private ::        two = 2.00_sp
     real(sp),    parameter, private ::      three = 3.00_sp
     real(sp),    parameter, private ::       four = 4.00_sp
     real(sp),    parameter, private ::      eight = 8.00_sp
     real(sp),    parameter, private ::        ten = 10.00_sp

     ! 32-bit complex constants 
     complex(sp), parameter, private :: czero   = ( 0.0_sp,0.0_sp)
     complex(sp), parameter, private :: chalf   = ( 0.5_sp,0.0_sp)
     complex(sp), parameter, private :: cone    = ( 1.0_sp,0.0_sp)
     complex(sp), parameter, private :: cnegone = (-1.0_sp,0.0_sp)

     ! 32-bit scaling constants 
     integer,     parameter, private :: maxexp = maxexponent(zero) 
     integer,     parameter, private :: minexp = minexponent(zero) 
     real(sp),    parameter, private :: rradix = real(radix(zero),sp) 
     real(sp),    parameter, private :: ulp    = epsilon(zero) 
     real(sp),    parameter, private :: eps    = ulp*half 
     real(sp),    parameter, private :: safmin = rradix**max(minexp-1,1-maxexp) 
     real(sp),    parameter, private :: safmax = one/safmin 
     real(sp),    parameter, private :: smlnum = safmin/ulp 
     real(sp),    parameter, private :: bignum = safmax*ulp 
     real(sp),    parameter, private :: rtmin  = sqrt(smlnum) 
     real(sp),    parameter, private :: rtmax  = sqrt(bignum) 

     ! 32-bit Blue's scaling constants 
     ! ssml>=1/s and sbig==1/S with s,S as defined in https://doi.org/10.1145/355769.355771 
     real(sp),    parameter, private :: tsml   = rradix**ceiling((minexp-1)*half) 
     real(sp),    parameter, private :: tbig   = rradix**floor((maxexp-digits(zero)+1)*half) 
     real(sp),    parameter, private :: ssml   = rradix**(-floor((minexp-digits(zero))*half)) 
     real(sp),    parameter, private :: sbig   = rradix**(-ceiling((maxexp+digits(zero)-1)*half)) 


     contains

     !> SASUM: takes the sum of the absolute values.
     !> uses unrolled loops for increment equal to one.

     pure real(sp) function stdlib_sasum(n,sx,incx)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, n
           ! Array Arguments 
           real(sp), intent(in) :: sx(*)
        ! =====================================================================
           ! Local Scalars 
           real(sp) :: stemp
           integer(ilp) :: i, m, mp1, nincx
           ! Intrinsic Functions 
           intrinsic :: abs,mod
           stdlib_sasum = zero
           stemp = zero
           if (n<=0 .or. incx<=0) return
           if (incx==1) then
              ! code for increment equal to 1
              ! clean-up loop
              m = mod(n,6)
              if (m/=0) then
                 do i = 1,m
                    stemp = stemp + abs(sx(i))
                 end do
                 if (n<6) then
                    stdlib_sasum = stemp
                    return
                 end if
              end if
              mp1 = m + 1
              do i = mp1,n,6
                 stemp = stemp + abs(sx(i)) + abs(sx(i+1)) +abs(sx(i+2)) + abs(sx(i+3)) +abs(sx(i+&
                           4)) + abs(sx(i+5))
              end do
           else
              ! code for increment not equal to 1
              nincx = n*incx
              do i = 1,nincx,incx
                 stemp = stemp + abs(sx(i))
              end do
           end if
           stdlib_sasum = stemp
           return
     end function stdlib_sasum

     !> SAXPY: constant times a vector plus a vector.
     !> uses unrolled loops for increments equal to one.

     pure subroutine stdlib_saxpy(n,sa,sx,incx,sy,incy)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: sa
           integer(ilp), intent(in) :: incx, incy, n
           ! Array Arguments 
           real(sp), intent(in) :: sx(*)
           real(sp), intent(inout) :: sy(*)
        ! =====================================================================
           ! Local Scalars 
           integer(ilp) :: i, ix, iy, m, mp1
           ! Intrinsic Functions 
           intrinsic :: mod
           if (n<=0) return
           if (sa==0.0_sp) return
           if (incx==1 .and. incy==1) then
              ! code for both increments equal to 1
              ! clean-up loop
              m = mod(n,4)
              if (m/=0) then
                 do i = 1,m
                    sy(i) = sy(i) + sa*sx(i)
                 end do
              end if
              if (n<4) return
              mp1 = m + 1
              do i = mp1,n,4
                 sy(i) = sy(i) + sa*sx(i)
                 sy(i+1) = sy(i+1) + sa*sx(i+1)
                 sy(i+2) = sy(i+2) + sa*sx(i+2)
                 sy(i+3) = sy(i+3) + sa*sx(i+3)
              end do
           else
              ! code for unequal increments or equal increments
                ! not equal to 1
              ix = 1
              iy = 1
              if (incx<0) ix = (-n+1)*incx + 1
              if (incy<0) iy = (-n+1)*incy + 1
              do i = 1,n
               sy(iy) = sy(iy) + sa*sx(ix)
               ix = ix + incx
               iy = iy + incy
              end do
           end if
           return
     end subroutine stdlib_saxpy

     !> SCASUM: takes the sum of the (|Re(.)| + |Im(.)|)'s of a complex vector and
     !> returns a single precision result.

     pure real(sp) function stdlib_scasum(n,cx,incx)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, n
           ! Array Arguments 
           complex(sp), intent(in) :: cx(*)
        ! =====================================================================
           ! Local Scalars 
           real(sp) :: stemp
           integer(ilp) :: i, nincx
           ! Intrinsic Functions 
           intrinsic :: abs,aimag,real
           stdlib_scasum = zero
           stemp = zero
           if (n<=0 .or. incx<=0) return
           if (incx==1) then
              ! code for increment equal to 1
              do i = 1,n
                 stemp = stemp + abs(real(cx(i),KIND=sp)) + abs(aimag(cx(i)))
              end do
           else
              ! code for increment not equal to 1
              nincx = n*incx
              do i = 1,nincx,incx
                 stemp = stemp + abs(real(cx(i),KIND=sp)) + abs(aimag(cx(i)))
              end do
           end if
           stdlib_scasum = stemp
           return
     end function stdlib_scasum

     !> !
     !>
     !> SCNRM2: returns the euclidean norm of a vector via the function
     !> name, so that
     !> SCNRM2 := sqrt( x**H*x )

     pure function stdlib_scnrm2( n, x, incx )
        real(sp) :: stdlib_scnrm2
        ! -- reference blas level1 routine (version 3.9.1_sp) --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! march 2021
        ! Constants 
        integer, parameter :: wp = kind(1._sp)
        real(sp), parameter :: maxn = huge(0.0_sp)
        ! .. blue's scaling constants ..
        ! Scalar Arguments 
     integer(ilp), intent(in) :: incx, n
        ! Array Arguments 
        complex(sp), intent(in) :: x(*)
        ! Local Scalars 
     integer(ilp) :: i, ix
     logical(lk) :: notbig
        real(sp) :: abig, amed, asml, ax, scl, sumsq, ymax, ymin
        ! quick return if possible
        stdlib_scnrm2 = zero
        if( n <= 0 ) return
        scl = one
        sumsq = zero
        ! compute the sum of squares in 3 accumulators:
           ! abig -- sums of squares scaled down to avoid overflow
           ! asml -- sums of squares scaled up to avoid underflow
           ! amed -- sums of squares that do not require scaling
        ! the thresholds and multipliers are
           ! tbig -- values bigger than this are scaled down by sbig
           ! tsml -- values smaller than this are scaled up by ssml
        notbig = .true.
        asml = zero
        amed = zero
        abig = zero
        ix = 1
        if( incx < 0 ) ix = 1 - (n-1)*incx
        do i = 1, n
           ax = abs(real(x(ix),KIND=sp))
           if (ax > tbig) then
              abig = abig + (ax*sbig)**2
              notbig = .false.
           else if (ax < tsml) then
              if (notbig) asml = asml + (ax*ssml)**2
           else
              amed = amed + ax**2
           end if
           ax = abs(aimag(x(ix)))
           if (ax > tbig) then
              abig = abig + (ax*sbig)**2
              notbig = .false.
           else if (ax < tsml) then
              if (notbig) asml = asml + (ax*ssml)**2
           else
              amed = amed + ax**2
           end if
           ix = ix + incx
        end do
        ! combine abig and amed or amed and asml if more than one
        ! accumulator was used.
        if (abig > zero) then
           ! combine abig and amed if abig > 0.
           if ( (amed > zero) .or. (amed > maxn) .or. (amed /= amed) ) then
              abig = abig + (amed*sbig)*sbig
           end if
           scl = one / sbig
           sumsq = abig
        else if (asml > zero) then
           ! combine amed and asml if asml > 0.
           if ( (amed > zero) .or. (amed > maxn) .or. (amed /= amed) ) then
              amed = sqrt(amed)
              asml = sqrt(asml) / ssml
              if (asml > amed) then
                 ymin = amed
                 ymax = asml
              else
                 ymin = asml
                 ymax = amed
              end if
              scl = one
              sumsq = ymax**2*( one + (ymin/ymax)**2 )
           else
              scl = one / ssml
              sumsq = asml
           end if
        else
           ! otherwise all values are mid-range
           scl = one
           sumsq = amed
        end if
        stdlib_scnrm2 = scl*sqrt( sumsq )
        return
     end function stdlib_scnrm2

     !> SCOPY: copies a vector, x, to a vector, y.
     !> uses unrolled loops for increments equal to 1.

     pure subroutine stdlib_scopy(n,sx,incx,sy,incy)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, incy, n
           ! Array Arguments 
           real(sp), intent(in) :: sx(*)
           real(sp), intent(out) :: sy(*)
        ! =====================================================================
           ! Local Scalars 
           integer(ilp) :: i, ix, iy, m, mp1
           ! Intrinsic Functions 
           intrinsic :: mod
           if (n<=0) return
           if (incx==1 .and. incy==1) then
              ! code for both increments equal to 1
              ! clean-up loop
              m = mod(n,7)
              if (m/=0) then
                 do i = 1,m
                    sy(i) = sx(i)
                 end do
                 if (n<7) return
              end if
              mp1 = m + 1
              do i = mp1,n,7
                 sy(i) = sx(i)
                 sy(i+1) = sx(i+1)
                 sy(i+2) = sx(i+2)
                 sy(i+3) = sx(i+3)
                 sy(i+4) = sx(i+4)
                 sy(i+5) = sx(i+5)
                 sy(i+6) = sx(i+6)
              end do
           else
              ! code for unequal increments or equal increments
                ! not equal to 1
              ix = 1
              iy = 1
              if (incx<0) ix = (-n+1)*incx + 1
              if (incy<0) iy = (-n+1)*incy + 1
              do i = 1,n
                 sy(iy) = sx(ix)
                 ix = ix + incx
                 iy = iy + incy
              end do
           end if
           return
     end subroutine stdlib_scopy

     !> SDOT: forms the dot product of two vectors.
     !> uses unrolled loops for increments equal to one.

     pure real(sp) function stdlib_sdot(n,sx,incx,sy,incy)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, incy, n
           ! Array Arguments 
           real(sp), intent(in) :: sx(*), sy(*)
        ! =====================================================================
           ! Local Scalars 
           real(sp) :: stemp
           integer(ilp) :: i, ix, iy, m, mp1
           ! Intrinsic Functions 
           intrinsic :: mod
           stemp = zero
           stdlib_sdot = zero
           if (n<=0) return
           if (incx==1 .and. incy==1) then
              ! code for both increments equal to 1
              ! clean-up loop
              m = mod(n,5)
              if (m/=0) then
                 do i = 1,m
                    stemp = stemp + sx(i)*sy(i)
                 end do
                 if (n<5) then
                    stdlib_sdot=stemp
                 return
                 end if
              end if
              mp1 = m + 1
              do i = mp1,n,5
               stemp = stemp + sx(i)*sy(i) + sx(i+1)*sy(i+1) +sx(i+2)*sy(i+2) + sx(i+3)*sy(i+3) + &
                         sx(i+4)*sy(i+4)
              end do
           else
              ! code for unequal increments or equal increments
                ! not equal to 1
              ix = 1
              iy = 1
              if (incx<0) ix = (-n+1)*incx + 1
              if (incy<0) iy = (-n+1)*incy + 1
              do i = 1,n
                 stemp = stemp + sx(ix)*sy(iy)
                 ix = ix + incx
                 iy = iy + incy
              end do
           end if
           stdlib_sdot = stemp
           return
     end function stdlib_sdot

     !> Compute the inner product of two vectors with extended
     !> precision accumulation.
     !> Returns S.P. result with dot product accumulated in D.P.
     !> SDSDOT: = SB + sum for I = 0 to N-1 of SX(LX+I*INCX)*SY(LY+I*INCY),
     !> where LX = 1 if INCX >= 0, else LX = 1+(1-N)*INCX, and LY is
     !> defined in a similar way using INCY.

     pure real(sp) function stdlib_sdsdot(n,sb,sx,incx,sy,incy)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: sb
           integer(ilp), intent(in) :: incx, incy, n
           ! Array Arguments 
           real(sp), intent(in) :: sx(*), sy(*)
           ! Local Scalars 
           real(dp) :: dsdot
           integer(ilp) :: i, kx, ky, ns
           ! Intrinsic Functions 
           intrinsic :: real
           dsdot = sb
           if (n<=0) then
              stdlib_sdsdot = dsdot
              return
           end if
           if (incx==incy .and. incx>0) then
           ! code for equal and positive increments.
              ns = n*incx
              do i = 1,ns,incx
                 dsdot = dsdot + real(sx(i),KIND=sp)*real(sy(i),KIND=sp)
              end do
           else
           ! code for unequal or nonpositive increments.
              kx = 1
              ky = 1
              if (incx<0) kx = 1 + (1-n)*incx
              if (incy<0) ky = 1 + (1-n)*incy
              do i = 1,n
                 dsdot = dsdot + real(sx(kx),KIND=sp)*real(sy(ky),KIND=sp)
                 kx = kx + incx
                 ky = ky + incy
              end do
           end if
           stdlib_sdsdot = dsdot
           return
     end function stdlib_sdsdot

     !> SGBMV:  performs one of the matrix-vector operations
     !> y := alpha*A*x + beta*y,   or   y := alpha*A**T*x + beta*y,
     !> where alpha and beta are scalars, x and y are vectors and A is an
     !> m by n band matrix, with kl sub-diagonals and ku super-diagonals.

     pure subroutine stdlib_sgbmv(trans,m,n,kl,ku,alpha,a,lda,x,incx,beta,y,incy)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: incx, incy, kl, ku, lda, m, n
           character, intent(in) :: trans
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*), x(*)
           real(sp), intent(inout) :: y(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, iy, j, jx, jy, k, kup1, kx, ky, lenx, leny
           ! Intrinsic Functions 
           intrinsic :: max,min
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(trans,'N') .and. .not.stdlib_lsame(trans,'T') &
                     .and..not.stdlib_lsame(trans,'C')) then
               info = 1
           else if (m<0) then
               info = 2
           else if (n<0) then
               info = 3
           else if (kl<0) then
               info = 4
           else if (ku<0) then
               info = 5
           else if (lda< (kl+ku+1)) then
               info = 8
           else if (incx==0) then
               info = 10
           else if (incy==0) then
               info = 13
           end if
           if (info/=0) then
               call stdlib_xerbla('SGBMV ',info)
               return
           end if
           ! quick return if possible.
           if ((m==0) .or. (n==0) .or.((alpha==zero).and. (beta==one))) return
           ! set  lenx  and  leny, the lengths of the vectors x and y, and set
           ! up the start points in  x  and  y.
           if (stdlib_lsame(trans,'N')) then
               lenx = n
               leny = m
           else
               lenx = m
               leny = n
           end if
           if (incx>0) then
               kx = 1
           else
               kx = 1 - (lenx-1)*incx
           end if
           if (incy>0) then
               ky = 1
           else
               ky = 1 - (leny-1)*incy
           end if
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through the band part of a.
           ! first form  y := beta*y.
           if (beta/=one) then
               if (incy==1) then
                   if (beta==zero) then
                       do i = 1,leny
                           y(i) = zero
                       end do
                   else
                       do i = 1,leny
                           y(i) = beta*y(i)
                       end do
                   end if
               else
                   iy = ky
                   if (beta==zero) then
                       do i = 1,leny
                           y(iy) = zero
                           iy = iy + incy
                       end do
                   else
                       do i = 1,leny
                           y(iy) = beta*y(iy)
                           iy = iy + incy
                       end do
                   end if
               end if
           end if
           if (alpha==zero) return
           kup1 = ku + 1
           if (stdlib_lsame(trans,'N')) then
              ! form  y := alpha*a*x + y.
               jx = kx
               if (incy==1) then
                   do j = 1,n
                       temp = alpha*x(jx)
                       k = kup1 - j
                       do i = max(1,j-ku),min(m,j+kl)
                           y(i) = y(i) + temp*a(k+i,j)
                       end do
                       jx = jx + incx
                   end do
               else
                   do j = 1,n
                       temp = alpha*x(jx)
                       iy = ky
                       k = kup1 - j
                       do i = max(1,j-ku),min(m,j+kl)
                           y(iy) = y(iy) + temp*a(k+i,j)
                           iy = iy + incy
                       end do
                       jx = jx + incx
                       if (j>ku) ky = ky + incy
                   end do
               end if
           else
              ! form  y := alpha*a**t*x + y.
               jy = ky
               if (incx==1) then
                   do j = 1,n
                       temp = zero
                       k = kup1 - j
                       do i = max(1,j-ku),min(m,j+kl)
                           temp = temp + a(k+i,j)*x(i)
                       end do
                       y(jy) = y(jy) + alpha*temp
                       jy = jy + incy
                   end do
               else
                   do j = 1,n
                       temp = zero
                       ix = kx
                       k = kup1 - j
                       do i = max(1,j-ku),min(m,j+kl)
                           temp = temp + a(k+i,j)*x(ix)
                           ix = ix + incx
                       end do
                       y(jy) = y(jy) + alpha*temp
                       jy = jy + incy
                       if (j>ku) kx = kx + incx
                   end do
               end if
           end if
           return
     end subroutine stdlib_sgbmv

     !> SGEMM:  performs one of the matrix-matrix operations
     !> C := alpha*op( A )*op( B ) + beta*C,
     !> where  op( X ) is one of
     !> op( X ) = X   or   op( X ) = X**T,
     !> alpha and beta are scalars, and A, B and C are matrices, with op( A )
     !> an m by k matrix,  op( B )  a  k by n matrix and  C an m by n matrix.

     pure subroutine stdlib_sgemm(transa,transb,m,n,k,alpha,a,lda,b,ldb,beta,c,ldc)
        ! -- reference blas level3 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: k, lda, ldb, ldc, m, n
           character, intent(in) :: transa, transb
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*), b(ldb,*)
           real(sp), intent(inout) :: c(ldc,*)
        ! =====================================================================
           ! Intrinsic Functions 
           intrinsic :: max
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, j, l, nrowa, nrowb
           logical(lk) :: nota, notb
           
           ! set  nota  and  notb  as  true if  a  and  b  respectively are not
           ! transposed and set  nrowa and nrowb  as the number of rows of  a
           ! and  b  respectively.
           nota = stdlib_lsame(transa,'N')
           notb = stdlib_lsame(transb,'N')
           if (nota) then
               nrowa = m
           else
               nrowa = k
           end if
           if (notb) then
               nrowb = k
           else
               nrowb = n
           end if
           ! test the input parameters.
           info = 0
           if ((.not.nota) .and. (.not.stdlib_lsame(transa,'C')) .and.(.not.stdlib_lsame(transa,&
                     'T'))) then
               info = 1
           else if ((.not.notb) .and. (.not.stdlib_lsame(transb,'C')) .and.(.not.stdlib_lsame(&
                     transb,'T'))) then
               info = 2
           else if (m<0) then
               info = 3
           else if (n<0) then
               info = 4
           else if (k<0) then
               info = 5
           else if (lda<max(1,nrowa)) then
               info = 8
           else if (ldb<max(1,nrowb)) then
               info = 10
           else if (ldc<max(1,m)) then
               info = 13
           end if
           if (info/=0) then
               call stdlib_xerbla('SGEMM ',info)
               return
           end if
           ! quick return if possible.
           if ((m==0) .or. (n==0) .or.(((alpha==zero).or. (k==0)).and. (beta==one))) &
                     return
           ! and if  alpha.eq.zero.
           if (alpha==zero) then
               if (beta==zero) then
                   do j = 1,n
                       do i = 1,m
                           c(i,j) = zero
                       end do
                   end do
               else
                   do j = 1,n
                       do i = 1,m
                           c(i,j) = beta*c(i,j)
                       end do
                   end do
               end if
               return
           end if
           ! start the operations.
           if (notb) then
               if (nota) then
                 ! form  c := alpha*a*b + beta*c.
                   do j = 1,n
                       if (beta==zero) then
                           do i = 1,m
                               c(i,j) = zero
                           end do
                       else if (beta/=one) then
                           do i = 1,m
                               c(i,j) = beta*c(i,j)
                           end do
                       end if
                       do l = 1,k
                           temp = alpha*b(l,j)
                           do i = 1,m
                               c(i,j) = c(i,j) + temp*a(i,l)
                           end do
                       end do
                   end do
               else
                 ! form  c := alpha*a**t*b + beta*c
                   do j = 1,n
                       do i = 1,m
                           temp = zero
                           do l = 1,k
                               temp = temp + a(l,i)*b(l,j)
                           end do
                           if (beta==zero) then
                               c(i,j) = alpha*temp
                           else
                               c(i,j) = alpha*temp + beta*c(i,j)
                           end if
                       end do
                   end do
               end if
           else
               if (nota) then
                 ! form  c := alpha*a*b**t + beta*c
                   do j = 1,n
                       if (beta==zero) then
                           do i = 1,m
                               c(i,j) = zero
                           end do
                       else if (beta/=one) then
                           do i = 1,m
                               c(i,j) = beta*c(i,j)
                           end do
                       end if
                       do l = 1,k
                           temp = alpha*b(j,l)
                           do i = 1,m
                               c(i,j) = c(i,j) + temp*a(i,l)
                           end do
                       end do
                   end do
               else
                 ! form  c := alpha*a**t*b**t + beta*c
                   do j = 1,n
                       do i = 1,m
                           temp = zero
                           do l = 1,k
                               temp = temp + a(l,i)*b(j,l)
                           end do
                           if (beta==zero) then
                               c(i,j) = alpha*temp
                           else
                               c(i,j) = alpha*temp + beta*c(i,j)
                           end if
                       end do
                   end do
               end if
           end if
           return
     end subroutine stdlib_sgemm

     !> SGEMV:  performs one of the matrix-vector operations
     !> y := alpha*A*x + beta*y,   or   y := alpha*A**T*x + beta*y,
     !> where alpha and beta are scalars, x and y are vectors and A is an
     !> m by n matrix.

     pure subroutine stdlib_sgemv(trans,m,n,alpha,a,lda,x,incx,beta,y,incy)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: incx, incy, lda, m, n
           character, intent(in) :: trans
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*), x(*)
           real(sp), intent(inout) :: y(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, iy, j, jx, jy, kx, ky, lenx, leny
           ! Intrinsic Functions 
           intrinsic :: max
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(trans,'N') .and. .not.stdlib_lsame(trans,'T') &
                     .and..not.stdlib_lsame(trans,'C')) then
               info = 1
           else if (m<0) then
               info = 2
           else if (n<0) then
               info = 3
           else if (lda<max(1,m)) then
               info = 6
           else if (incx==0) then
               info = 8
           else if (incy==0) then
               info = 11
           end if
           if (info/=0) then
               call stdlib_xerbla('SGEMV ',info)
               return
           end if
           ! quick return if possible.
           if ((m==0) .or. (n==0) .or.((alpha==zero).and. (beta==one))) return
           ! set  lenx  and  leny, the lengths of the vectors x and y, and set
           ! up the start points in  x  and  y.
           if (stdlib_lsame(trans,'N')) then
               lenx = n
               leny = m
           else
               lenx = m
               leny = n
           end if
           if (incx>0) then
               kx = 1
           else
               kx = 1 - (lenx-1)*incx
           end if
           if (incy>0) then
               ky = 1
           else
               ky = 1 - (leny-1)*incy
           end if
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through a.
           ! first form  y := beta*y.
           if (beta/=one) then
               if (incy==1) then
                   if (beta==zero) then
                       do i = 1,leny
                           y(i) = zero
                       end do
                   else
                       do i = 1,leny
                           y(i) = beta*y(i)
                       end do
                   end if
               else
                   iy = ky
                   if (beta==zero) then
                       do i = 1,leny
                           y(iy) = zero
                           iy = iy + incy
                       end do
                   else
                       do i = 1,leny
                           y(iy) = beta*y(iy)
                           iy = iy + incy
                       end do
                   end if
               end if
           end if
           if (alpha==zero) return
           if (stdlib_lsame(trans,'N')) then
              ! form  y := alpha*a*x + y.
               jx = kx
               if (incy==1) then
                   do j = 1,n
                       temp = alpha*x(jx)
                       do i = 1,m
                           y(i) = y(i) + temp*a(i,j)
                       end do
                       jx = jx + incx
                   end do
               else
                   do j = 1,n
                       temp = alpha*x(jx)
                       iy = ky
                       do i = 1,m
                           y(iy) = y(iy) + temp*a(i,j)
                           iy = iy + incy
                       end do
                       jx = jx + incx
                   end do
               end if
           else
              ! form  y := alpha*a**t*x + y.
               jy = ky
               if (incx==1) then
                   do j = 1,n
                       temp = zero
                       do i = 1,m
                           temp = temp + a(i,j)*x(i)
                       end do
                       y(jy) = y(jy) + alpha*temp
                       jy = jy + incy
                   end do
               else
                   do j = 1,n
                       temp = zero
                       ix = kx
                       do i = 1,m
                           temp = temp + a(i,j)*x(ix)
                           ix = ix + incx
                       end do
                       y(jy) = y(jy) + alpha*temp
                       jy = jy + incy
                   end do
               end if
           end if
           return
     end subroutine stdlib_sgemv

     !> SGER:   performs the rank 1 operation
     !> A := alpha*x*y**T + A,
     !> where alpha is a scalar, x is an m element vector, y is an n element
     !> vector and A is an m by n matrix.

     pure subroutine stdlib_sger(m,n,alpha,x,incx,y,incy,a,lda)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha
           integer(ilp), intent(in) :: incx, incy, lda, m, n
           ! Array Arguments 
           real(sp), intent(inout) :: a(lda,*)
           real(sp), intent(in) :: x(*), y(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jy, kx
           ! Intrinsic Functions 
           intrinsic :: max
           ! test the input parameters.
           info = 0
           if (m<0) then
               info = 1
           else if (n<0) then
               info = 2
           else if (incx==0) then
               info = 5
           else if (incy==0) then
               info = 7
           else if (lda<max(1,m)) then
               info = 9
           end if
           if (info/=0) then
               call stdlib_xerbla('SGER  ',info)
               return
           end if
           ! quick return if possible.
           if ((m==0) .or. (n==0) .or. (alpha==zero)) return
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through a.
           if (incy>0) then
               jy = 1
           else
               jy = 1 - (n-1)*incy
           end if
           if (incx==1) then
               do j = 1,n
                   if (y(jy)/=zero) then
                       temp = alpha*y(jy)
                       do i = 1,m
                           a(i,j) = a(i,j) + x(i)*temp
                       end do
                   end if
                   jy = jy + incy
               end do
           else
               if (incx>0) then
                   kx = 1
               else
                   kx = 1 - (m-1)*incx
               end if
               do j = 1,n
                   if (y(jy)/=zero) then
                       temp = alpha*y(jy)
                       ix = kx
                       do i = 1,m
                           a(i,j) = a(i,j) + x(ix)*temp
                           ix = ix + incx
                       end do
                   end if
                   jy = jy + incy
               end do
           end if
           return
     end subroutine stdlib_sger

     !> !
     !>
     !> SNRM2: returns the euclidean norm of a vector via the function
     !> name, so that
     !> SNRM2 := sqrt( x'*x ).

     pure function stdlib_snrm2( n, x, incx )
        real(sp) :: stdlib_snrm2
        ! -- reference blas level1 routine (version 3.9.1_sp) --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! march 2021
        ! Constants 
        integer, parameter :: wp = kind(1._sp)
        real(sp), parameter :: maxn = huge(0.0_sp)
        ! .. blue's scaling constants ..
        ! Scalar Arguments 
     integer(ilp), intent(in) :: incx, n
        ! Array Arguments 
        real(sp), intent(in) :: x(*)
        ! Local Scalars 
     integer(ilp) :: i, ix
     logical(lk) :: notbig
        real(sp) :: abig, amed, asml, ax, scl, sumsq, ymax, ymin
        ! quick return if possible
        stdlib_snrm2 = zero
        if( n <= 0 ) return
        scl = one
        sumsq = zero
        ! compute the sum of squares in 3 accumulators:
           ! abig -- sums of squares scaled down to avoid overflow
           ! asml -- sums of squares scaled up to avoid underflow
           ! amed -- sums of squares that do not require scaling
        ! the thresholds and multipliers are
           ! tbig -- values bigger than this are scaled down by sbig
           ! tsml -- values smaller than this are scaled up by ssml
        notbig = .true.
        asml = zero
        amed = zero
        abig = zero
        ix = 1
        if( incx < 0 ) ix = 1 - (n-1)*incx
        do i = 1, n
           ax = abs(x(ix))
           if (ax > tbig) then
              abig = abig + (ax*sbig)**2
              notbig = .false.
           else if (ax < tsml) then
              if (notbig) asml = asml + (ax*ssml)**2
           else
              amed = amed + ax**2
           end if
           ix = ix + incx
        end do
        ! combine abig and amed or amed and asml if more than one
        ! accumulator was used.
        if (abig > zero) then
           ! combine abig and amed if abig > 0.
           if ( (amed > zero) .or. (amed > maxn) .or. (amed /= amed) ) then
              abig = abig + (amed*sbig)*sbig
           end if
           scl = one / sbig
           sumsq = abig
        else if (asml > zero) then
           ! combine amed and asml if asml > 0.
           if ( (amed > zero) .or. (amed > maxn) .or. (amed /= amed) ) then
              amed = sqrt(amed)
              asml = sqrt(asml) / ssml
              if (asml > amed) then
                 ymin = amed
                 ymax = asml
              else
                 ymin = asml
                 ymax = amed
              end if
              scl = one
              sumsq = ymax**2*( one + (ymin/ymax)**2 )
           else
              scl = one / ssml
              sumsq = asml
           end if
        else
           ! otherwise all values are mid-range
           scl = one
           sumsq = amed
        end if
        stdlib_snrm2 = scl*sqrt( sumsq )
        return
     end function stdlib_snrm2

     !> applies a plane rotation.

     pure subroutine stdlib_srot(n,sx,incx,sy,incy,c,s)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: c, s
           integer(ilp), intent(in) :: incx, incy, n
           ! Array Arguments 
           real(sp), intent(inout) :: sx(*), sy(*)
        ! =====================================================================
           ! Local Scalars 
           real(sp) :: stemp
           integer(ilp) :: i, ix, iy
           if (n<=0) return
           if (incx==1 .and. incy==1) then
             ! code for both increments equal to 1
              do i = 1,n
                 stemp = c*sx(i) + s*sy(i)
                 sy(i) = c*sy(i) - s*sx(i)
                 sx(i) = stemp
              end do
           else
             ! code for unequal increments or equal increments not equal
               ! to 1
              ix = 1
              iy = 1
              if (incx<0) ix = (-n+1)*incx + 1
              if (incy<0) iy = (-n+1)*incy + 1
              do i = 1,n
                 stemp = c*sx(ix) + s*sy(iy)
                 sy(iy) = c*sy(iy) - s*sx(ix)
                 sx(ix) = stemp
                 ix = ix + incx
                 iy = iy + incy
              end do
           end if
           return
     end subroutine stdlib_srot

     !> !
     !>
     !> The computation uses the formulas
     !> sigma = sgn(a)    if |a| >  |b|
     !> = sgn(b)    if |b| >= |a|
     !> r = sigma*sqrt( a**2 + b**2 )
     !> c = 1; s = 0      if r = 0
     !> c = a/r; s = b/r  if r != 0
     !> The subroutine also computes
     !> z = s    if |a| > |b|,
     !> = 1/c  if |b| >= |a| and c != 0
     !> = 1    if c = 0
     !> This allows c and s to be reconstructed from z as follows:
     !> If z = 1, set c = 0, s = 1.
     !> If |z| < 1, set c = sqrt(1 - z**2) and s = z.
     !> If |z| > 1, set c = 1/z and s = sqrt( 1 - c**2).

     pure subroutine stdlib_srotg( a, b, c, s )
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
        ! Constants 
        integer, parameter :: wp = kind(1._sp)
        ! Scaling Constants 
        ! Scalar Arguments 
        real(sp), intent(inout) :: a, b
        real(sp), intent(out) :: c, s
        ! Local Scalars 
        real(sp) :: anorm, bnorm, scl, sigma, r, z
        anorm = abs(a)
        bnorm = abs(b)
        if( bnorm == zero ) then
           c = one
           s = zero
           b = zero
        else if( anorm == zero ) then
           c = zero
           s = one
           a = b
           b = one
        else
           scl = min( safmax, max( safmin, anorm, bnorm ) )
           if( anorm > bnorm ) then
              sigma = sign(one,a)
           else
              sigma = sign(one,b)
           end if
           r = sigma*( scl*sqrt((a/scl)**2 + (b/scl)**2) )
           c = a/r
           s = b/r
           if( anorm > bnorm ) then
              z = s
           else if( c /= zero ) then
              z = one/c
           else
              z = one
           end if
           a = r
           b = z
        end if
        return
     end subroutine stdlib_srotg

     !> APPLY THE MODIFIED GIVENS TRANSFORMATION, H, TO THE 2 BY N MATRIX
     !> (SX**T) , WHERE **T INDICATES TRANSPOSE. THE ELEMENTS OF SX ARE IN
     !> (SX**T)
     !> SX(LX+I*INCX), I = 0 TO N-1, WHERE LX = 1 IF INCX >= 0, ELSE
     !> LX = (-INCX)*N, AND SIMILARLY FOR SY USING USING LY AND INCY.
     !> WITH SPARAM(1)=SFLAG, H HAS ONE OF THE FOLLOWING FORMS..
     !> SFLAG=-1._sp     SFLAG=0._sp        SFLAG=1._sp     SFLAG=-2.E0
     !> (SH11  SH12)    (1._sp  SH12)    (SH11  1._sp)    (1._sp  0._sp)
     !> H=(          )    (          )    (          )    (          )
     !> (SH21  SH22),   (SH21  1._sp),   (-1._sp SH22),   (0._sp  1._sp).
     !> SEE  SROTMG FOR A DESCRIPTION OF DATA STORAGE IN SPARAM.

     pure subroutine stdlib_srotm(n,sx,incx,sy,incy,sparam)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, incy, n
           ! Array Arguments 
           real(sp), intent(in) :: sparam(5)
           real(sp), intent(inout) :: sx(*), sy(*)
        ! =====================================================================
           ! Local Scalars 
           real(sp) :: sflag, sh11, sh12, sh21, sh22, two, w, z, zero
           integer(ilp) :: i, kx, ky, nsteps
           ! Data Statements 
           zero = 0.0_sp
           two = 2.0_sp
           sflag = sparam(1)
           if (n<=0 .or. (sflag+two==zero)) return
           if (incx==incy.and.incx>0) then
              nsteps = n*incx
              if (sflag<zero) then
                 sh11 = sparam(2)
                 sh12 = sparam(4)
                 sh21 = sparam(3)
                 sh22 = sparam(5)
                 do i = 1,nsteps,incx
                    w = sx(i)
                    z = sy(i)
                    sx(i) = w*sh11 + z*sh12
                    sy(i) = w*sh21 + z*sh22
                 end do
              else if (sflag==zero) then
                 sh12 = sparam(4)
                 sh21 = sparam(3)
                 do i = 1,nsteps,incx
                    w = sx(i)
                    z = sy(i)
                    sx(i) = w + z*sh12
                    sy(i) = w*sh21 + z
                 end do
              else
                 sh11 = sparam(2)
                 sh22 = sparam(5)
                 do i = 1,nsteps,incx
                    w = sx(i)
                    z = sy(i)
                    sx(i) = w*sh11 + z
                    sy(i) = -w + sh22*z
                 end do
              end if
           else
              kx = 1
              ky = 1
              if (incx<0) kx = 1 + (1-n)*incx
              if (incy<0) ky = 1 + (1-n)*incy
              if (sflag<zero) then
                 sh11 = sparam(2)
                 sh12 = sparam(4)
                 sh21 = sparam(3)
                 sh22 = sparam(5)
                 do i = 1,n
                    w = sx(kx)
                    z = sy(ky)
                    sx(kx) = w*sh11 + z*sh12
                    sy(ky) = w*sh21 + z*sh22
                    kx = kx + incx
                    ky = ky + incy
                 end do
              else if (sflag==zero) then
                 sh12 = sparam(4)
                 sh21 = sparam(3)
                 do i = 1,n
                    w = sx(kx)
                    z = sy(ky)
                    sx(kx) = w + z*sh12
                    sy(ky) = w*sh21 + z
                    kx = kx + incx
                    ky = ky + incy
                 end do
              else
                  sh11 = sparam(2)
                  sh22 = sparam(5)
                  do i = 1,n
                     w = sx(kx)
                     z = sy(ky)
                     sx(kx) = w*sh11 + z
                     sy(ky) = -w + sh22*z
                     kx = kx + incx
                     ky = ky + incy
                 end do
              end if
           end if
           return
     end subroutine stdlib_srotm

     !> CONSTRUCT THE MODIFIED GIVENS TRANSFORMATION MATRIX H WHICH ZEROS
     !> THE SECOND COMPONENT OF THE 2-VECTOR  (SQRT(SD1)*SX1,SQRT(SD2)    SY2)**T.
     !> WITH SPARAM(1)=SFLAG, H HAS ONE OF THE FOLLOWING FORMS..
     !> SFLAG=-1._sp     SFLAG=0._sp        SFLAG=1._sp     SFLAG=-2.E0
     !> (SH11  SH12)    (1._sp  SH12)    (SH11  1._sp)    (1._sp  0._sp)
     !> H=(          )    (          )    (          )    (          )
     !> (SH21  SH22),   (SH21  1._sp),   (-1._sp SH22),   (0._sp  1._sp).
     !> LOCATIONS 2-4 OF SPARAM CONTAIN SH11,SH21,SH12, AND SH22
     !> RESPECTIVELY. (VALUES OF 1._sp, -1._sp, OR 0._sp IMPLIED BY THE
     !> VALUE OF SPARAM(1) ARE NOT STORED IN SPARAM.)
     !> THE VALUES OF GAMSQ AND RGAMSQ SET IN THE DATA STATEMENT MAY BE
     !> INEXACT.  THIS IS OK AS THEY ARE ONLY USED FOR TESTING THE SIZE
     !> OF SD1 AND SD2.  ALL ACTUAL SCALING OF DATA IS DONE USING GAM.

     pure subroutine stdlib_srotmg(sd1,sd2,sx1,sy1,sparam)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(inout) :: sd1, sd2, sx1
           real(sp), intent(in) :: sy1
           ! Array Arguments 
           real(sp), intent(out) :: sparam(5)
        ! =====================================================================
           ! Local Scalars 
           real(sp) :: gam, gamsq, one, rgamsq, sflag, sh11, sh12, sh21, sh22, sp1, sp2, sq1, sq2,&
                      stemp, su, two, zero
           ! Intrinsic Functions 
           intrinsic :: abs
           ! Data Statements 
           zero = 0.0_sp
           one = 1.0_sp
           two = 2.0_sp
           gam = 4096.0_sp
           gamsq = 1.67772e7_sp
           rgamsq = 5.96046e-8_sp
           if (sd1<zero) then
              ! go zero-h-d-and-sx1..
              sflag = -one
              sh11 = zero
              sh12 = zero
              sh21 = zero
              sh22 = zero
              sd1 = zero
              sd2 = zero
              sx1 = zero
           else
              ! case-sd1-nonnegative
              sp2 = sd2*sy1
              if (sp2==zero) then
                 sflag = -two
                 sparam(1) = sflag
                 return
              end if
              ! regular-case..
              sp1 = sd1*sx1
              sq2 = sp2*sy1
              sq1 = sp1*sx1
              if (abs(sq1)>abs(sq2)) then
                 sh21 = -sy1/sx1
                 sh12 = sp2/sp1
                 su = one - sh12*sh21
                if (su>zero) then
                  sflag = zero
                  sd1 = sd1/su
                  sd2 = sd2/su
                  sx1 = sx1*su
                else
                  ! this code path if here for safety. we do not expect this
                  ! condition to ever hold except in edge cases with rounding
                  ! errors. see doi: 10.1145/355841.355847
                  sflag = -one
                  sh11 = zero
                  sh12 = zero
                  sh21 = zero
                  sh22 = zero
                  sd1 = zero
                  sd2 = zero
                  sx1 = zero
                end if
              else
                 if (sq2<zero) then
                    ! go zero-h-d-and-sx1..
                    sflag = -one
                    sh11 = zero
                    sh12 = zero
                    sh21 = zero
                    sh22 = zero
                    sd1 = zero
                    sd2 = zero
                    sx1 = zero
                 else
                    sflag = one
                    sh11 = sp1/sp2
                    sh22 = sx1/sy1
                    su = one + sh11*sh22
                    stemp = sd2/su
                    sd2 = sd1/su
                    sd1 = stemp
                    sx1 = sy1*su
                 end if
              end if
           ! procedure..scale-check
              if (sd1/=zero) then
                 do while ((sd1<=rgamsq) .or. (sd1>=gamsq))
                    if (sflag==zero) then
                       sh11 = one
                       sh22 = one
                       sflag = -one
                    else
                       sh21 = -one
                       sh12 = one
                       sflag = -one
                    end if
                    if (sd1<=rgamsq) then
                       sd1 = sd1*gam**2
                       sx1 = sx1/gam
                       sh11 = sh11/gam
                       sh12 = sh12/gam
                    else
                       sd1 = sd1/gam**2
                       sx1 = sx1*gam
                       sh11 = sh11*gam
                       sh12 = sh12*gam
                    end if
                 enddo
              end if
              if (sd2/=zero) then
                 do while ( (abs(sd2)<=rgamsq) .or. (abs(sd2)>=gamsq) )
                    if (sflag==zero) then
                       sh11 = one
                       sh22 = one
                       sflag = -one
                    else
                       sh21 = -one
                       sh12 = one
                       sflag = -one
                    end if
                    if (abs(sd2)<=rgamsq) then
                       sd2 = sd2*gam**2
                       sh21 = sh21/gam
                       sh22 = sh22/gam
                    else
                       sd2 = sd2/gam**2
                       sh21 = sh21*gam
                       sh22 = sh22*gam
                    end if
                 end do
              end if
           end if
           if (sflag<zero) then
              sparam(2) = sh11
              sparam(3) = sh21
              sparam(4) = sh12
              sparam(5) = sh22
           else if (sflag==zero) then
              sparam(3) = sh21
              sparam(4) = sh12
           else
              sparam(2) = sh11
              sparam(5) = sh22
           end if
           sparam(1) = sflag
           return
     end subroutine stdlib_srotmg

     !> SSBMV:  performs the matrix-vector  operation
     !> y := alpha*A*x + beta*y,
     !> where alpha and beta are scalars, x and y are n element vectors and
     !> A is an n by n symmetric band matrix, with k super-diagonals.

     pure subroutine stdlib_ssbmv(uplo,n,k,alpha,a,lda,x,incx,beta,y,incy)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: incx, incy, k, lda, n
           character, intent(in) :: uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*), x(*)
           real(sp), intent(inout) :: y(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp1, temp2
           integer(ilp) :: i, info, ix, iy, j, jx, jy, kplus1, kx, ky, l
           ! Intrinsic Functions 
           intrinsic :: max,min
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (n<0) then
               info = 2
           else if (k<0) then
               info = 3
           else if (lda< (k+1)) then
               info = 6
           else if (incx==0) then
               info = 8
           else if (incy==0) then
               info = 11
           end if
           if (info/=0) then
               call stdlib_xerbla('SSBMV ',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. ((alpha==zero).and. (beta==one))) return
           ! set up the start points in  x  and  y.
           if (incx>0) then
               kx = 1
           else
               kx = 1 - (n-1)*incx
           end if
           if (incy>0) then
               ky = 1
           else
               ky = 1 - (n-1)*incy
           end if
           ! start the operations. in this version the elements of the array a
           ! are accessed sequentially with one pass through a.
           ! first form  y := beta*y.
           if (beta/=one) then
               if (incy==1) then
                   if (beta==zero) then
                       do i = 1,n
                           y(i) = zero
                       end do
                   else
                       do i = 1,n
                           y(i) = beta*y(i)
                       end do
                   end if
               else
                   iy = ky
                   if (beta==zero) then
                       do i = 1,n
                           y(iy) = zero
                           iy = iy + incy
                       end do
                   else
                       do i = 1,n
                           y(iy) = beta*y(iy)
                           iy = iy + incy
                       end do
                   end if
               end if
           end if
           if (alpha==zero) return
           if (stdlib_lsame(uplo,'U')) then
              ! form  y  when upper triangle of a is stored.
               kplus1 = k + 1
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       temp1 = alpha*x(j)
                       temp2 = zero
                       l = kplus1 - j
                       do i = max(1,j-k),j - 1
                           y(i) = y(i) + temp1*a(l+i,j)
                           temp2 = temp2 + a(l+i,j)*x(i)
                       end do
                       y(j) = y(j) + temp1*a(kplus1,j) + alpha*temp2
                   end do
               else
                   jx = kx
                   jy = ky
                   do j = 1,n
                       temp1 = alpha*x(jx)
                       temp2 = zero
                       ix = kx
                       iy = ky
                       l = kplus1 - j
                       do i = max(1,j-k),j - 1
                           y(iy) = y(iy) + temp1*a(l+i,j)
                           temp2 = temp2 + a(l+i,j)*x(ix)
                           ix = ix + incx
                           iy = iy + incy
                       end do
                       y(jy) = y(jy) + temp1*a(kplus1,j) + alpha*temp2
                       jx = jx + incx
                       jy = jy + incy
                       if (j>k) then
                           kx = kx + incx
                           ky = ky + incy
                       end if
                   end do
               end if
           else
              ! form  y  when lower triangle of a is stored.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       temp1 = alpha*x(j)
                       temp2 = zero
                       y(j) = y(j) + temp1*a(1,j)
                       l = 1 - j
                       do i = j + 1,min(n,j+k)
                           y(i) = y(i) + temp1*a(l+i,j)
                           temp2 = temp2 + a(l+i,j)*x(i)
                       end do
                       y(j) = y(j) + alpha*temp2
                   end do
               else
                   jx = kx
                   jy = ky
                   do j = 1,n
                       temp1 = alpha*x(jx)
                       temp2 = zero
                       y(jy) = y(jy) + temp1*a(1,j)
                       l = 1 - j
                       ix = jx
                       iy = jy
                       do i = j + 1,min(n,j+k)
                           ix = ix + incx
                           iy = iy + incy
                           y(iy) = y(iy) + temp1*a(l+i,j)
                           temp2 = temp2 + a(l+i,j)*x(ix)
                       end do
                       y(jy) = y(jy) + alpha*temp2
                       jx = jx + incx
                       jy = jy + incy
                   end do
               end if
           end if
           return
     end subroutine stdlib_ssbmv

     !> SSCAL: scales a vector by a constant.
     !> uses unrolled loops for increment equal to 1.

     pure subroutine stdlib_sscal(n,sa,sx,incx)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: sa
           integer(ilp), intent(in) :: incx, n
           ! Array Arguments 
           real(sp), intent(inout) :: sx(*)
        ! =====================================================================
           ! Local Scalars 
           integer(ilp) :: i, m, mp1, nincx
           ! Intrinsic Functions 
           intrinsic :: mod
           if (n<=0 .or. incx<=0) return
           if (incx==1) then
              ! code for increment equal to 1
              ! clean-up loop
              m = mod(n,5)
              if (m/=0) then
                 do i = 1,m
                    sx(i) = sa*sx(i)
                 end do
                 if (n<5) return
              end if
              mp1 = m + 1
              do i = mp1,n,5
                 sx(i) = sa*sx(i)
                 sx(i+1) = sa*sx(i+1)
                 sx(i+2) = sa*sx(i+2)
                 sx(i+3) = sa*sx(i+3)
                 sx(i+4) = sa*sx(i+4)
              end do
           else
              ! code for increment not equal to 1
              nincx = n*incx
              do i = 1,nincx,incx
                 sx(i) = sa*sx(i)
              end do
           end if
           return
     end subroutine stdlib_sscal

     !> SSPMV:  performs the matrix-vector operation
     !> y := alpha*A*x + beta*y,
     !> where alpha and beta are scalars, x and y are n element vectors and
     !> A is an n by n symmetric matrix, supplied in packed form.

     pure subroutine stdlib_sspmv(uplo,n,alpha,ap,x,incx,beta,y,incy)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: incx, incy, n
           character, intent(in) :: uplo
           ! Array Arguments 
           real(sp), intent(in) :: ap(*), x(*)
           real(sp), intent(inout) :: y(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp1, temp2
           integer(ilp) :: i, info, ix, iy, j, jx, jy, k, kk, kx, ky
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (n<0) then
               info = 2
           else if (incx==0) then
               info = 6
           else if (incy==0) then
               info = 9
           end if
           if (info/=0) then
               call stdlib_xerbla('SSPMV ',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. ((alpha==zero).and. (beta==one))) return
           ! set up the start points in  x  and  y.
           if (incx>0) then
               kx = 1
           else
               kx = 1 - (n-1)*incx
           end if
           if (incy>0) then
               ky = 1
           else
               ky = 1 - (n-1)*incy
           end if
           ! start the operations. in this version the elements of the array ap
           ! are accessed sequentially with one pass through ap.
           ! first form  y := beta*y.
           if (beta/=one) then
               if (incy==1) then
                   if (beta==zero) then
                       do i = 1,n
                           y(i) = zero
                       end do
                   else
                       do i = 1,n
                           y(i) = beta*y(i)
                       end do
                   end if
               else
                   iy = ky
                   if (beta==zero) then
                       do i = 1,n
                           y(iy) = zero
                           iy = iy + incy
                       end do
                   else
                       do i = 1,n
                           y(iy) = beta*y(iy)
                           iy = iy + incy
                       end do
                   end if
               end if
           end if
           if (alpha==zero) return
           kk = 1
           if (stdlib_lsame(uplo,'U')) then
              ! form  y  when ap contains the upper triangle.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       temp1 = alpha*x(j)
                       temp2 = zero
                       k = kk
                       do i = 1,j - 1
                           y(i) = y(i) + temp1*ap(k)
                           temp2 = temp2 + ap(k)*x(i)
                           k = k + 1
                       end do
                       y(j) = y(j) + temp1*ap(kk+j-1) + alpha*temp2
                       kk = kk + j
                   end do
               else
                   jx = kx
                   jy = ky
                   do j = 1,n
                       temp1 = alpha*x(jx)
                       temp2 = zero
                       ix = kx
                       iy = ky
                       do k = kk,kk + j - 2
                           y(iy) = y(iy) + temp1*ap(k)
                           temp2 = temp2 + ap(k)*x(ix)
                           ix = ix + incx
                           iy = iy + incy
                       end do
                       y(jy) = y(jy) + temp1*ap(kk+j-1) + alpha*temp2
                       jx = jx + incx
                       jy = jy + incy
                       kk = kk + j
                   end do
               end if
           else
              ! form  y  when ap contains the lower triangle.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       temp1 = alpha*x(j)
                       temp2 = zero
                       y(j) = y(j) + temp1*ap(kk)
                       k = kk + 1
                       do i = j + 1,n
                           y(i) = y(i) + temp1*ap(k)
                           temp2 = temp2 + ap(k)*x(i)
                           k = k + 1
                       end do
                       y(j) = y(j) + alpha*temp2
                       kk = kk + (n-j+1)
                   end do
               else
                   jx = kx
                   jy = ky
                   do j = 1,n
                       temp1 = alpha*x(jx)
                       temp2 = zero
                       y(jy) = y(jy) + temp1*ap(kk)
                       ix = jx
                       iy = jy
                       do k = kk + 1,kk + n - j
                           ix = ix + incx
                           iy = iy + incy
                           y(iy) = y(iy) + temp1*ap(k)
                           temp2 = temp2 + ap(k)*x(ix)
                       end do
                       y(jy) = y(jy) + alpha*temp2
                       jx = jx + incx
                       jy = jy + incy
                       kk = kk + (n-j+1)
                   end do
               end if
           end if
           return
     end subroutine stdlib_sspmv

     !> SSPR:    performs the symmetric rank 1 operation
     !> A := alpha*x*x**T + A,
     !> where alpha is a real scalar, x is an n element vector and A is an
     !> n by n symmetric matrix, supplied in packed form.

     pure subroutine stdlib_sspr(uplo,n,alpha,x,incx,ap)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha
           integer(ilp), intent(in) :: incx, n
           character, intent(in) :: uplo
           ! Array Arguments 
           real(sp), intent(inout) :: ap(*)
           real(sp), intent(in) :: x(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jx, k, kk, kx
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (n<0) then
               info = 2
           else if (incx==0) then
               info = 5
           end if
           if (info/=0) then
               call stdlib_xerbla('SSPR  ',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. (alpha==zero)) return
           ! set the start point in x if the increment is not unity.
           if (incx<=0) then
               kx = 1 - (n-1)*incx
           else if (incx/=1) then
               kx = 1
           end if
           ! start the operations. in this version the elements of the array ap
           ! are accessed sequentially with one pass through ap.
           kk = 1
           if (stdlib_lsame(uplo,'U')) then
              ! form  a  when upper triangle is stored in ap.
               if (incx==1) then
                   do j = 1,n
                       if (x(j)/=zero) then
                           temp = alpha*x(j)
                           k = kk
                           do i = 1,j
                               ap(k) = ap(k) + x(i)*temp
                               k = k + 1
                           end do
                       end if
                       kk = kk + j
                   end do
               else
                   jx = kx
                   do j = 1,n
                       if (x(jx)/=zero) then
                           temp = alpha*x(jx)
                           ix = kx
                           do k = kk,kk + j - 1
                               ap(k) = ap(k) + x(ix)*temp
                               ix = ix + incx
                           end do
                       end if
                       jx = jx + incx
                       kk = kk + j
                   end do
               end if
           else
              ! form  a  when lower triangle is stored in ap.
               if (incx==1) then
                   do j = 1,n
                       if (x(j)/=zero) then
                           temp = alpha*x(j)
                           k = kk
                           do i = j,n
                               ap(k) = ap(k) + x(i)*temp
                               k = k + 1
                           end do
                       end if
                       kk = kk + n - j + 1
                   end do
               else
                   jx = kx
                   do j = 1,n
                       if (x(jx)/=zero) then
                           temp = alpha*x(jx)
                           ix = jx
                           do k = kk,kk + n - j
                               ap(k) = ap(k) + x(ix)*temp
                               ix = ix + incx
                           end do
                       end if
                       jx = jx + incx
                       kk = kk + n - j + 1
                   end do
               end if
           end if
           return
     end subroutine stdlib_sspr

     !> SSPR2:  performs the symmetric rank 2 operation
     !> A := alpha*x*y**T + alpha*y*x**T + A,
     !> where alpha is a scalar, x and y are n element vectors and A is an
     !> n by n symmetric matrix, supplied in packed form.

     pure subroutine stdlib_sspr2(uplo,n,alpha,x,incx,y,incy,ap)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha
           integer(ilp), intent(in) :: incx, incy, n
           character, intent(in) :: uplo
           ! Array Arguments 
           real(sp), intent(inout) :: ap(*)
           real(sp), intent(in) :: x(*), y(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp1, temp2
           integer(ilp) :: i, info, ix, iy, j, jx, jy, k, kk, kx, ky
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (n<0) then
               info = 2
           else if (incx==0) then
               info = 5
           else if (incy==0) then
               info = 7
           end if
           if (info/=0) then
               call stdlib_xerbla('SSPR2 ',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. (alpha==zero)) return
           ! set up the start points in x and y if the increments are not both
           ! unity.
           if ((incx/=1) .or. (incy/=1)) then
               if (incx>0) then
                   kx = 1
               else
                   kx = 1 - (n-1)*incx
               end if
               if (incy>0) then
                   ky = 1
               else
                   ky = 1 - (n-1)*incy
               end if
               jx = kx
               jy = ky
           end if
           ! start the operations. in this version the elements of the array ap
           ! are accessed sequentially with one pass through ap.
           kk = 1
           if (stdlib_lsame(uplo,'U')) then
              ! form  a  when upper triangle is stored in ap.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       if ((x(j)/=zero) .or. (y(j)/=zero)) then
                           temp1 = alpha*y(j)
                           temp2 = alpha*x(j)
                           k = kk
                           do i = 1,j
                               ap(k) = ap(k) + x(i)*temp1 + y(i)*temp2
                               k = k + 1
                           end do
                       end if
                       kk = kk + j
                   end do
               else
                   do j = 1,n
                       if ((x(jx)/=zero) .or. (y(jy)/=zero)) then
                           temp1 = alpha*y(jy)
                           temp2 = alpha*x(jx)
                           ix = kx
                           iy = ky
                           do k = kk,kk + j - 1
                               ap(k) = ap(k) + x(ix)*temp1 + y(iy)*temp2
                               ix = ix + incx
                               iy = iy + incy
                           end do
                       end if
                       jx = jx + incx
                       jy = jy + incy
                       kk = kk + j
                   end do
               end if
           else
              ! form  a  when lower triangle is stored in ap.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       if ((x(j)/=zero) .or. (y(j)/=zero)) then
                           temp1 = alpha*y(j)
                           temp2 = alpha*x(j)
                           k = kk
                           do i = j,n
                               ap(k) = ap(k) + x(i)*temp1 + y(i)*temp2
                               k = k + 1
                           end do
                       end if
                       kk = kk + n - j + 1
                   end do
               else
                   do j = 1,n
                       if ((x(jx)/=zero) .or. (y(jy)/=zero)) then
                           temp1 = alpha*y(jy)
                           temp2 = alpha*x(jx)
                           ix = jx
                           iy = jy
                           do k = kk,kk + n - j
                               ap(k) = ap(k) + x(ix)*temp1 + y(iy)*temp2
                               ix = ix + incx
                               iy = iy + incy
                           end do
                       end if
                       jx = jx + incx
                       jy = jy + incy
                       kk = kk + n - j + 1
                   end do
               end if
           end if
           return
     end subroutine stdlib_sspr2

     !> SSWAP: interchanges two vectors.
     !> uses unrolled loops for increments equal to 1.

     pure subroutine stdlib_sswap(n,sx,incx,sy,incy)
        ! -- reference blas level1 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, incy, n
           ! Array Arguments 
           real(sp), intent(inout) :: sx(*), sy(*)
        ! =====================================================================
           ! Local Scalars 
           real(sp) :: stemp
           integer(ilp) :: i, ix, iy, m, mp1
           ! Intrinsic Functions 
           intrinsic :: mod
           if (n<=0) return
           if (incx==1 .and. incy==1) then
             ! code for both increments equal to 1
             ! clean-up loop
              m = mod(n,3)
              if (m/=0) then
                 do i = 1,m
                    stemp = sx(i)
                    sx(i) = sy(i)
                    sy(i) = stemp
                 end do
                 if (n<3) return
              end if
              mp1 = m + 1
              do i = mp1,n,3
                 stemp = sx(i)
                 sx(i) = sy(i)
                 sy(i) = stemp
                 stemp = sx(i+1)
                 sx(i+1) = sy(i+1)
                 sy(i+1) = stemp
                 stemp = sx(i+2)
                 sx(i+2) = sy(i+2)
                 sy(i+2) = stemp
              end do
           else
             ! code for unequal increments or equal increments not equal
               ! to 1
              ix = 1
              iy = 1
              if (incx<0) ix = (-n+1)*incx + 1
              if (incy<0) iy = (-n+1)*incy + 1
              do i = 1,n
                 stemp = sx(ix)
                 sx(ix) = sy(iy)
                 sy(iy) = stemp
                 ix = ix + incx
                 iy = iy + incy
              end do
           end if
           return
     end subroutine stdlib_sswap

     !> SSYMM:  performs one of the matrix-matrix operations
     !> C := alpha*A*B + beta*C,
     !> or
     !> C := alpha*B*A + beta*C,
     !> where alpha and beta are scalars,  A is a symmetric matrix and  B and
     !> C are  m by n matrices.

     pure subroutine stdlib_ssymm(side,uplo,m,n,alpha,a,lda,b,ldb,beta,c,ldc)
        ! -- reference blas level3 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: lda, ldb, ldc, m, n
           character, intent(in) :: side, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*), b(ldb,*)
           real(sp), intent(inout) :: c(ldc,*)
        ! =====================================================================
           ! Intrinsic Functions 
           intrinsic :: max
           ! Local Scalars 
           real(sp) :: temp1, temp2
           integer(ilp) :: i, info, j, k, nrowa
           logical(lk) :: upper
           
           ! set nrowa as the number of rows of a.
           if (stdlib_lsame(side,'L')) then
               nrowa = m
           else
               nrowa = n
           end if
           upper = stdlib_lsame(uplo,'U')
           ! test the input parameters.
           info = 0
           if ((.not.stdlib_lsame(side,'L')) .and. (.not.stdlib_lsame(side,'R'))) then
               info = 1
           else if ((.not.upper) .and. (.not.stdlib_lsame(uplo,'L'))) then
               info = 2
           else if (m<0) then
               info = 3
           else if (n<0) then
               info = 4
           else if (lda<max(1,nrowa)) then
               info = 7
           else if (ldb<max(1,m)) then
               info = 9
           else if (ldc<max(1,m)) then
               info = 12
           end if
           if (info/=0) then
               call stdlib_xerbla('SSYMM ',info)
               return
           end if
           ! quick return if possible.
           if ((m==0) .or. (n==0) .or.((alpha==zero).and. (beta==one))) return
           ! and when  alpha.eq.zero.
           if (alpha==zero) then
               if (beta==zero) then
                   do j = 1,n
                       do i = 1,m
                           c(i,j) = zero
                       end do
                   end do
               else
                   do j = 1,n
                       do i = 1,m
                           c(i,j) = beta*c(i,j)
                       end do
                   end do
               end if
               return
           end if
           ! start the operations.
           if (stdlib_lsame(side,'L')) then
              ! form  c := alpha*a*b + beta*c.
               if (upper) then
                   do j = 1,n
                       do i = 1,m
                           temp1 = alpha*b(i,j)
                           temp2 = zero
                           do k = 1,i - 1
                               c(k,j) = c(k,j) + temp1*a(k,i)
                               temp2 = temp2 + b(k,j)*a(k,i)
                           end do
                           if (beta==zero) then
                               c(i,j) = temp1*a(i,i) + alpha*temp2
                           else
                               c(i,j) = beta*c(i,j) + temp1*a(i,i) +alpha*temp2
                           end if
                       end do
                   end do
               else
                   do j = 1,n
                       do i = m,1,-1
                           temp1 = alpha*b(i,j)
                           temp2 = zero
                           do k = i + 1,m
                               c(k,j) = c(k,j) + temp1*a(k,i)
                               temp2 = temp2 + b(k,j)*a(k,i)
                           end do
                           if (beta==zero) then
                               c(i,j) = temp1*a(i,i) + alpha*temp2
                           else
                               c(i,j) = beta*c(i,j) + temp1*a(i,i) +alpha*temp2
                           end if
                       end do
                   end do
               end if
           else
              ! form  c := alpha*b*a + beta*c.
               loop_170: do j = 1,n
                   temp1 = alpha*a(j,j)
                   if (beta==zero) then
                       do i = 1,m
                           c(i,j) = temp1*b(i,j)
                       end do
                   else
                       do i = 1,m
                           c(i,j) = beta*c(i,j) + temp1*b(i,j)
                       end do
                   end if
                   do k = 1,j - 1
                       if (upper) then
                           temp1 = alpha*a(k,j)
                       else
                           temp1 = alpha*a(j,k)
                       end if
                       do i = 1,m
                           c(i,j) = c(i,j) + temp1*b(i,k)
                       end do
                   end do
                   do k = j + 1,n
                       if (upper) then
                           temp1 = alpha*a(j,k)
                       else
                           temp1 = alpha*a(k,j)
                       end if
                       do i = 1,m
                           c(i,j) = c(i,j) + temp1*b(i,k)
                       end do
                   end do
               end do loop_170
           end if
           return
     end subroutine stdlib_ssymm

     !> SSYMV:  performs the matrix-vector  operation
     !> y := alpha*A*x + beta*y,
     !> where alpha and beta are scalars, x and y are n element vectors and
     !> A is an n by n symmetric matrix.

     pure subroutine stdlib_ssymv(uplo,n,alpha,a,lda,x,incx,beta,y,incy)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: incx, incy, lda, n
           character, intent(in) :: uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*), x(*)
           real(sp), intent(inout) :: y(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp1, temp2
           integer(ilp) :: i, info, ix, iy, j, jx, jy, kx, ky
           ! Intrinsic Functions 
           intrinsic :: max
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (n<0) then
               info = 2
           else if (lda<max(1,n)) then
               info = 5
           else if (incx==0) then
               info = 7
           else if (incy==0) then
               info = 10
           end if
           if (info/=0) then
               call stdlib_xerbla('SSYMV ',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. ((alpha==zero).and. (beta==one))) return
           ! set up the start points in  x  and  y.
           if (incx>0) then
               kx = 1
           else
               kx = 1 - (n-1)*incx
           end if
           if (incy>0) then
               ky = 1
           else
               ky = 1 - (n-1)*incy
           end if
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through the triangular part
           ! of a.
           ! first form  y := beta*y.
           if (beta/=one) then
               if (incy==1) then
                   if (beta==zero) then
                       do i = 1,n
                           y(i) = zero
                       end do
                   else
                       do i = 1,n
                           y(i) = beta*y(i)
                       end do
                   end if
               else
                   iy = ky
                   if (beta==zero) then
                       do i = 1,n
                           y(iy) = zero
                           iy = iy + incy
                       end do
                   else
                       do i = 1,n
                           y(iy) = beta*y(iy)
                           iy = iy + incy
                       end do
                   end if
               end if
           end if
           if (alpha==zero) return
           if (stdlib_lsame(uplo,'U')) then
              ! form  y  when a is stored in upper triangle.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       temp1 = alpha*x(j)
                       temp2 = zero
                       do i = 1,j - 1
                           y(i) = y(i) + temp1*a(i,j)
                           temp2 = temp2 + a(i,j)*x(i)
                       end do
                       y(j) = y(j) + temp1*a(j,j) + alpha*temp2
                   end do
               else
                   jx = kx
                   jy = ky
                   do j = 1,n
                       temp1 = alpha*x(jx)
                       temp2 = zero
                       ix = kx
                       iy = ky
                       do i = 1,j - 1
                           y(iy) = y(iy) + temp1*a(i,j)
                           temp2 = temp2 + a(i,j)*x(ix)
                           ix = ix + incx
                           iy = iy + incy
                       end do
                       y(jy) = y(jy) + temp1*a(j,j) + alpha*temp2
                       jx = jx + incx
                       jy = jy + incy
                   end do
               end if
           else
              ! form  y  when a is stored in lower triangle.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       temp1 = alpha*x(j)
                       temp2 = zero
                       y(j) = y(j) + temp1*a(j,j)
                       do i = j + 1,n
                           y(i) = y(i) + temp1*a(i,j)
                           temp2 = temp2 + a(i,j)*x(i)
                       end do
                       y(j) = y(j) + alpha*temp2
                   end do
               else
                   jx = kx
                   jy = ky
                   do j = 1,n
                       temp1 = alpha*x(jx)
                       temp2 = zero
                       y(jy) = y(jy) + temp1*a(j,j)
                       ix = jx
                       iy = jy
                       do i = j + 1,n
                           ix = ix + incx
                           iy = iy + incy
                           y(iy) = y(iy) + temp1*a(i,j)
                           temp2 = temp2 + a(i,j)*x(ix)
                       end do
                       y(jy) = y(jy) + alpha*temp2
                       jx = jx + incx
                       jy = jy + incy
                   end do
               end if
           end if
           return
     end subroutine stdlib_ssymv

     !> SSYR:   performs the symmetric rank 1 operation
     !> A := alpha*x*x**T + A,
     !> where alpha is a real scalar, x is an n element vector and A is an
     !> n by n symmetric matrix.

     pure subroutine stdlib_ssyr(uplo,n,alpha,x,incx,a,lda)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha
           integer(ilp), intent(in) :: incx, lda, n
           character, intent(in) :: uplo
           ! Array Arguments 
           real(sp), intent(inout) :: a(lda,*)
           real(sp), intent(in) :: x(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jx, kx
           ! Intrinsic Functions 
           intrinsic :: max
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (n<0) then
               info = 2
           else if (incx==0) then
               info = 5
           else if (lda<max(1,n)) then
               info = 7
           end if
           if (info/=0) then
               call stdlib_xerbla('SSYR  ',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. (alpha==zero)) return
           ! set the start point in x if the increment is not unity.
           if (incx<=0) then
               kx = 1 - (n-1)*incx
           else if (incx/=1) then
               kx = 1
           end if
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through the triangular part
           ! of a.
           if (stdlib_lsame(uplo,'U')) then
              ! form  a  when a is stored in upper triangle.
               if (incx==1) then
                   do j = 1,n
                       if (x(j)/=zero) then
                           temp = alpha*x(j)
                           do i = 1,j
                               a(i,j) = a(i,j) + x(i)*temp
                           end do
                       end if
                   end do
               else
                   jx = kx
                   do j = 1,n
                       if (x(jx)/=zero) then
                           temp = alpha*x(jx)
                           ix = kx
                           do i = 1,j
                               a(i,j) = a(i,j) + x(ix)*temp
                               ix = ix + incx
                           end do
                       end if
                       jx = jx + incx
                   end do
               end if
           else
              ! form  a  when a is stored in lower triangle.
               if (incx==1) then
                   do j = 1,n
                       if (x(j)/=zero) then
                           temp = alpha*x(j)
                           do i = j,n
                               a(i,j) = a(i,j) + x(i)*temp
                           end do
                       end if
                   end do
               else
                   jx = kx
                   do j = 1,n
                       if (x(jx)/=zero) then
                           temp = alpha*x(jx)
                           ix = jx
                           do i = j,n
                               a(i,j) = a(i,j) + x(ix)*temp
                               ix = ix + incx
                           end do
                       end if
                       jx = jx + incx
                   end do
               end if
           end if
           return
     end subroutine stdlib_ssyr

     !> SSYR2:  performs the symmetric rank 2 operation
     !> A := alpha*x*y**T + alpha*y*x**T + A,
     !> where alpha is a scalar, x and y are n element vectors and A is an n
     !> by n symmetric matrix.

     pure subroutine stdlib_ssyr2(uplo,n,alpha,x,incx,y,incy,a,lda)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha
           integer(ilp), intent(in) :: incx, incy, lda, n
           character, intent(in) :: uplo
           ! Array Arguments 
           real(sp), intent(inout) :: a(lda,*)
           real(sp), intent(in) :: x(*), y(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp1, temp2
           integer(ilp) :: i, info, ix, iy, j, jx, jy, kx, ky
           ! Intrinsic Functions 
           intrinsic :: max
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (n<0) then
               info = 2
           else if (incx==0) then
               info = 5
           else if (incy==0) then
               info = 7
           else if (lda<max(1,n)) then
               info = 9
           end if
           if (info/=0) then
               call stdlib_xerbla('SSYR2 ',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. (alpha==zero)) return
           ! set up the start points in x and y if the increments are not both
           ! unity.
           if ((incx/=1) .or. (incy/=1)) then
               if (incx>0) then
                   kx = 1
               else
                   kx = 1 - (n-1)*incx
               end if
               if (incy>0) then
                   ky = 1
               else
                   ky = 1 - (n-1)*incy
               end if
               jx = kx
               jy = ky
           end if
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through the triangular part
           ! of a.
           if (stdlib_lsame(uplo,'U')) then
              ! form  a  when a is stored in the upper triangle.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       if ((x(j)/=zero) .or. (y(j)/=zero)) then
                           temp1 = alpha*y(j)
                           temp2 = alpha*x(j)
                           do i = 1,j
                               a(i,j) = a(i,j) + x(i)*temp1 + y(i)*temp2
                           end do
                       end if
                   end do
               else
                   do j = 1,n
                       if ((x(jx)/=zero) .or. (y(jy)/=zero)) then
                           temp1 = alpha*y(jy)
                           temp2 = alpha*x(jx)
                           ix = kx
                           iy = ky
                           do i = 1,j
                               a(i,j) = a(i,j) + x(ix)*temp1 + y(iy)*temp2
                               ix = ix + incx
                               iy = iy + incy
                           end do
                       end if
                       jx = jx + incx
                       jy = jy + incy
                   end do
               end if
           else
              ! form  a  when a is stored in the lower triangle.
               if ((incx==1) .and. (incy==1)) then
                   do j = 1,n
                       if ((x(j)/=zero) .or. (y(j)/=zero)) then
                           temp1 = alpha*y(j)
                           temp2 = alpha*x(j)
                           do i = j,n
                               a(i,j) = a(i,j) + x(i)*temp1 + y(i)*temp2
                           end do
                       end if
                   end do
               else
                   do j = 1,n
                       if ((x(jx)/=zero) .or. (y(jy)/=zero)) then
                           temp1 = alpha*y(jy)
                           temp2 = alpha*x(jx)
                           ix = jx
                           iy = jy
                           do i = j,n
                               a(i,j) = a(i,j) + x(ix)*temp1 + y(iy)*temp2
                               ix = ix + incx
                               iy = iy + incy
                           end do
                       end if
                       jx = jx + incx
                       jy = jy + incy
                   end do
               end if
           end if
           return
     end subroutine stdlib_ssyr2

     !> SSYR2K:  performs one of the symmetric rank 2k operations
     !> C := alpha*A*B**T + alpha*B*A**T + beta*C,
     !> or
     !> C := alpha*A**T*B + alpha*B**T*A + beta*C,
     !> where  alpha and beta  are scalars, C is an  n by n  symmetric matrix
     !> and  A and B  are  n by k  matrices  in the  first  case  and  k by n
     !> matrices in the second case.

     pure subroutine stdlib_ssyr2k(uplo,trans,n,k,alpha,a,lda,b,ldb,beta,c,ldc)
        ! -- reference blas level3 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: k, lda, ldb, ldc, n
           character, intent(in) :: trans, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*), b(ldb,*)
           real(sp), intent(inout) :: c(ldc,*)
        ! =====================================================================
           ! Intrinsic Functions 
           intrinsic :: max
           ! Local Scalars 
           real(sp) :: temp1, temp2
           integer(ilp) :: i, info, j, l, nrowa
           logical(lk) :: upper
           
           ! test the input parameters.
           if (stdlib_lsame(trans,'N')) then
               nrowa = n
           else
               nrowa = k
           end if
           upper = stdlib_lsame(uplo,'U')
           info = 0
           if ((.not.upper) .and. (.not.stdlib_lsame(uplo,'L'))) then
               info = 1
           else if ((.not.stdlib_lsame(trans,'N')) .and.(.not.stdlib_lsame(trans,'T')) .and.(&
                     .not.stdlib_lsame(trans,'C'))) then
               info = 2
           else if (n<0) then
               info = 3
           else if (k<0) then
               info = 4
           else if (lda<max(1,nrowa)) then
               info = 7
           else if (ldb<max(1,nrowa)) then
               info = 9
           else if (ldc<max(1,n)) then
               info = 12
           end if
           if (info/=0) then
               call stdlib_xerbla('SSYR2K',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. (((alpha==zero).or.(k==0)).and. (beta==one))) return
           ! and when  alpha.eq.zero.
           if (alpha==zero) then
               if (upper) then
                   if (beta==zero) then
                       do j = 1,n
                           do i = 1,j
                               c(i,j) = zero
                           end do
                       end do
                   else
                       do j = 1,n
                           do i = 1,j
                               c(i,j) = beta*c(i,j)
                           end do
                       end do
                   end if
               else
                   if (beta==zero) then
                       do j = 1,n
                           do i = j,n
                               c(i,j) = zero
                           end do
                       end do
                   else
                       do j = 1,n
                           do i = j,n
                               c(i,j) = beta*c(i,j)
                           end do
                       end do
                   end if
               end if
               return
           end if
           ! start the operations.
           if (stdlib_lsame(trans,'N')) then
              ! form  c := alpha*a*b**t + alpha*b*a**t + c.
               if (upper) then
                   do j = 1,n
                       if (beta==zero) then
                           do i = 1,j
                               c(i,j) = zero
                           end do
                       else if (beta/=one) then
                           do i = 1,j
                               c(i,j) = beta*c(i,j)
                           end do
                       end if
                       do l = 1,k
                           if ((a(j,l)/=zero) .or. (b(j,l)/=zero)) then
                               temp1 = alpha*b(j,l)
                               temp2 = alpha*a(j,l)
                               do i = 1,j
                                   c(i,j) = c(i,j) + a(i,l)*temp1 +b(i,l)*temp2
                               end do
                           end if
                       end do
                   end do
               else
                   do j = 1,n
                       if (beta==zero) then
                           do i = j,n
                               c(i,j) = zero
                           end do
                       else if (beta/=one) then
                           do i = j,n
                               c(i,j) = beta*c(i,j)
                           end do
                       end if
                       do l = 1,k
                           if ((a(j,l)/=zero) .or. (b(j,l)/=zero)) then
                               temp1 = alpha*b(j,l)
                               temp2 = alpha*a(j,l)
                               do i = j,n
                                   c(i,j) = c(i,j) + a(i,l)*temp1 +b(i,l)*temp2
                               end do
                           end if
                       end do
                   end do
               end if
           else
              ! form  c := alpha*a**t*b + alpha*b**t*a + c.
               if (upper) then
                   do j = 1,n
                       do i = 1,j
                           temp1 = zero
                           temp2 = zero
                           do l = 1,k
                               temp1 = temp1 + a(l,i)*b(l,j)
                               temp2 = temp2 + b(l,i)*a(l,j)
                           end do
                           if (beta==zero) then
                               c(i,j) = alpha*temp1 + alpha*temp2
                           else
                               c(i,j) = beta*c(i,j) + alpha*temp1 +alpha*temp2
                           end if
                       end do
                   end do
               else
                   do j = 1,n
                       do i = j,n
                           temp1 = zero
                           temp2 = zero
                           do l = 1,k
                               temp1 = temp1 + a(l,i)*b(l,j)
                               temp2 = temp2 + b(l,i)*a(l,j)
                           end do
                           if (beta==zero) then
                               c(i,j) = alpha*temp1 + alpha*temp2
                           else
                               c(i,j) = beta*c(i,j) + alpha*temp1 +alpha*temp2
                           end if
                       end do
                   end do
               end if
           end if
           return
     end subroutine stdlib_ssyr2k

     !> SSYRK:  performs one of the symmetric rank k operations
     !> C := alpha*A*A**T + beta*C,
     !> or
     !> C := alpha*A**T*A + beta*C,
     !> where  alpha and beta  are scalars, C is an  n by n  symmetric matrix
     !> and  A  is an  n by k  matrix in the first case and a  k by n  matrix
     !> in the second case.

     pure subroutine stdlib_ssyrk(uplo,trans,n,k,alpha,a,lda,beta,c,ldc)
        ! -- reference blas level3 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha, beta
           integer(ilp), intent(in) :: k, lda, ldc, n
           character, intent(in) :: trans, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*)
           real(sp), intent(inout) :: c(ldc,*)
        ! =====================================================================
           ! Intrinsic Functions 
           intrinsic :: max
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, j, l, nrowa
           logical(lk) :: upper
           
           ! test the input parameters.
           if (stdlib_lsame(trans,'N')) then
               nrowa = n
           else
               nrowa = k
           end if
           upper = stdlib_lsame(uplo,'U')
           info = 0
           if ((.not.upper) .and. (.not.stdlib_lsame(uplo,'L'))) then
               info = 1
           else if ((.not.stdlib_lsame(trans,'N')) .and.(.not.stdlib_lsame(trans,'T')) .and.(&
                     .not.stdlib_lsame(trans,'C'))) then
               info = 2
           else if (n<0) then
               info = 3
           else if (k<0) then
               info = 4
           else if (lda<max(1,nrowa)) then
               info = 7
           else if (ldc<max(1,n)) then
               info = 10
           end if
           if (info/=0) then
               call stdlib_xerbla('SSYRK ',info)
               return
           end if
           ! quick return if possible.
           if ((n==0) .or. (((alpha==zero).or.(k==0)).and. (beta==one))) return
           ! and when  alpha.eq.zero.
           if (alpha==zero) then
               if (upper) then
                   if (beta==zero) then
                       do j = 1,n
                           do i = 1,j
                               c(i,j) = zero
                           end do
                       end do
                   else
                       do j = 1,n
                           do i = 1,j
                               c(i,j) = beta*c(i,j)
                           end do
                       end do
                   end if
               else
                   if (beta==zero) then
                       do j = 1,n
                           do i = j,n
                               c(i,j) = zero
                           end do
                       end do
                   else
                       do j = 1,n
                           do i = j,n
                               c(i,j) = beta*c(i,j)
                           end do
                       end do
                   end if
               end if
               return
           end if
           ! start the operations.
           if (stdlib_lsame(trans,'N')) then
              ! form  c := alpha*a*a**t + beta*c.
               if (upper) then
                   do j = 1,n
                       if (beta==zero) then
                           do i = 1,j
                               c(i,j) = zero
                           end do
                       else if (beta/=one) then
                           do i = 1,j
                               c(i,j) = beta*c(i,j)
                           end do
                       end if
                       do l = 1,k
                           if (a(j,l)/=zero) then
                               temp = alpha*a(j,l)
                               do i = 1,j
                                   c(i,j) = c(i,j) + temp*a(i,l)
                               end do
                           end if
                       end do
                   end do
               else
                   do j = 1,n
                       if (beta==zero) then
                           do i = j,n
                               c(i,j) = zero
                           end do
                       else if (beta/=one) then
                           do i = j,n
                               c(i,j) = beta*c(i,j)
                           end do
                       end if
                       do l = 1,k
                           if (a(j,l)/=zero) then
                               temp = alpha*a(j,l)
                               do i = j,n
                                   c(i,j) = c(i,j) + temp*a(i,l)
                               end do
                           end if
                       end do
                   end do
               end if
           else
              ! form  c := alpha*a**t*a + beta*c.
               if (upper) then
                   do j = 1,n
                       do i = 1,j
                           temp = zero
                           do l = 1,k
                               temp = temp + a(l,i)*a(l,j)
                           end do
                           if (beta==zero) then
                               c(i,j) = alpha*temp
                           else
                               c(i,j) = alpha*temp + beta*c(i,j)
                           end if
                       end do
                   end do
               else
                   do j = 1,n
                       do i = j,n
                           temp = zero
                           do l = 1,k
                               temp = temp + a(l,i)*a(l,j)
                           end do
                           if (beta==zero) then
                               c(i,j) = alpha*temp
                           else
                               c(i,j) = alpha*temp + beta*c(i,j)
                           end if
                       end do
                   end do
               end if
           end if
           return
     end subroutine stdlib_ssyrk

     !> STBMV:  performs one of the matrix-vector operations
     !> x := A*x,   or   x := A**T*x,
     !> where x is an n element vector and  A is an n by n unit, or non-unit,
     !> upper or lower triangular band matrix, with ( k + 1 ) diagonals.

     pure subroutine stdlib_stbmv(uplo,trans,diag,n,k,a,lda,x,incx)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, k, lda, n
           character, intent(in) :: diag, trans, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*)
           real(sp), intent(inout) :: x(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jx, kplus1, kx, l
           logical(lk) :: nounit
           ! Intrinsic Functions 
           intrinsic :: max,min
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (.not.stdlib_lsame(trans,'N') .and. .not.stdlib_lsame(trans,'T') &
                     .and..not.stdlib_lsame(trans,'C')) then
               info = 2
           else if (.not.stdlib_lsame(diag,'U') .and. .not.stdlib_lsame(diag,'N')) then
               info = 3
           else if (n<0) then
               info = 4
           else if (k<0) then
               info = 5
           else if (lda< (k+1)) then
               info = 7
           else if (incx==0) then
               info = 9
           end if
           if (info/=0) then
               call stdlib_xerbla('STBMV ',info)
               return
           end if
           ! quick return if possible.
           if (n==0) return
           nounit = stdlib_lsame(diag,'N')
           ! set up the start point in x if the increment is not unity. this
           ! will be  ( n - 1 )*incx   too small for descending loops.
           if (incx<=0) then
               kx = 1 - (n-1)*incx
           else if (incx/=1) then
               kx = 1
           end if
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through a.
           if (stdlib_lsame(trans,'N')) then
               ! form  x := a*x.
               if (stdlib_lsame(uplo,'U')) then
                   kplus1 = k + 1
                   if (incx==1) then
                       do j = 1,n
                           if (x(j)/=zero) then
                               temp = x(j)
                               l = kplus1 - j
                               do i = max(1,j-k),j - 1
                                   x(i) = x(i) + temp*a(l+i,j)
                               end do
                               if (nounit) x(j) = x(j)*a(kplus1,j)
                           end if
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           if (x(jx)/=zero) then
                               temp = x(jx)
                               ix = kx
                               l = kplus1 - j
                               do i = max(1,j-k),j - 1
                                   x(ix) = x(ix) + temp*a(l+i,j)
                                   ix = ix + incx
                               end do
                               if (nounit) x(jx) = x(jx)*a(kplus1,j)
                           end if
                           jx = jx + incx
                           if (j>k) kx = kx + incx
                       end do
                   end if
               else
                   if (incx==1) then
                       do j = n,1,-1
                           if (x(j)/=zero) then
                               temp = x(j)
                               l = 1 - j
                               do i = min(n,j+k),j + 1,-1
                                   x(i) = x(i) + temp*a(l+i,j)
                               end do
                               if (nounit) x(j) = x(j)*a(1,j)
                           end if
                       end do
                   else
                       kx = kx + (n-1)*incx
                       jx = kx
                       do j = n,1,-1
                           if (x(jx)/=zero) then
                               temp = x(jx)
                               ix = kx
                               l = 1 - j
                               do i = min(n,j+k),j + 1,-1
                                   x(ix) = x(ix) + temp*a(l+i,j)
                                   ix = ix - incx
                               end do
                               if (nounit) x(jx) = x(jx)*a(1,j)
                           end if
                           jx = jx - incx
                           if ((n-j)>=k) kx = kx - incx
                       end do
                   end if
               end if
           else
              ! form  x := a**t*x.
               if (stdlib_lsame(uplo,'U')) then
                   kplus1 = k + 1
                   if (incx==1) then
                       do j = n,1,-1
                           temp = x(j)
                           l = kplus1 - j
                           if (nounit) temp = temp*a(kplus1,j)
                           do i = j - 1,max(1,j-k),-1
                               temp = temp + a(l+i,j)*x(i)
                           end do
                           x(j) = temp
                       end do
                   else
                       kx = kx + (n-1)*incx
                       jx = kx
                       do j = n,1,-1
                           temp = x(jx)
                           kx = kx - incx
                           ix = kx
                           l = kplus1 - j
                           if (nounit) temp = temp*a(kplus1,j)
                           do i = j - 1,max(1,j-k),-1
                               temp = temp + a(l+i,j)*x(ix)
                               ix = ix - incx
                           end do
                           x(jx) = temp
                           jx = jx - incx
                       end do
                   end if
               else
                   if (incx==1) then
                       do j = 1,n
                           temp = x(j)
                           l = 1 - j
                           if (nounit) temp = temp*a(1,j)
                           do i = j + 1,min(n,j+k)
                               temp = temp + a(l+i,j)*x(i)
                           end do
                           x(j) = temp
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           temp = x(jx)
                           kx = kx + incx
                           ix = kx
                           l = 1 - j
                           if (nounit) temp = temp*a(1,j)
                           do i = j + 1,min(n,j+k)
                               temp = temp + a(l+i,j)*x(ix)
                               ix = ix + incx
                           end do
                           x(jx) = temp
                           jx = jx + incx
                       end do
                   end if
               end if
           end if
           return
     end subroutine stdlib_stbmv

     !> STBSV:  solves one of the systems of equations
     !> A*x = b,   or   A**T*x = b,
     !> where b and x are n element vectors and A is an n by n unit, or
     !> non-unit, upper or lower triangular band matrix, with ( k + 1 )
     !> diagonals.
     !> No test for singularity or near-singularity is included in this
     !> routine. Such tests must be performed before calling this routine.

     pure subroutine stdlib_stbsv(uplo,trans,diag,n,k,a,lda,x,incx)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, k, lda, n
           character, intent(in) :: diag, trans, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*)
           real(sp), intent(inout) :: x(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jx, kplus1, kx, l
           logical(lk) :: nounit
           ! Intrinsic Functions 
           intrinsic :: max,min
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (.not.stdlib_lsame(trans,'N') .and. .not.stdlib_lsame(trans,'T') &
                     .and..not.stdlib_lsame(trans,'C')) then
               info = 2
           else if (.not.stdlib_lsame(diag,'U') .and. .not.stdlib_lsame(diag,'N')) then
               info = 3
           else if (n<0) then
               info = 4
           else if (k<0) then
               info = 5
           else if (lda< (k+1)) then
               info = 7
           else if (incx==0) then
               info = 9
           end if
           if (info/=0) then
               call stdlib_xerbla('STBSV ',info)
               return
           end if
           ! quick return if possible.
           if (n==0) return
           nounit = stdlib_lsame(diag,'N')
           ! set up the start point in x if the increment is not unity. this
           ! will be  ( n - 1 )*incx  too small for descending loops.
           if (incx<=0) then
               kx = 1 - (n-1)*incx
           else if (incx/=1) then
               kx = 1
           end if
           ! start the operations. in this version the elements of a are
           ! accessed by sequentially with one pass through a.
           if (stdlib_lsame(trans,'N')) then
              ! form  x := inv( a )*x.
               if (stdlib_lsame(uplo,'U')) then
                   kplus1 = k + 1
                   if (incx==1) then
                       do j = n,1,-1
                           if (x(j)/=zero) then
                               l = kplus1 - j
                               if (nounit) x(j) = x(j)/a(kplus1,j)
                               temp = x(j)
                               do i = j - 1,max(1,j-k),-1
                                   x(i) = x(i) - temp*a(l+i,j)
                               end do
                           end if
                       end do
                   else
                       kx = kx + (n-1)*incx
                       jx = kx
                       do j = n,1,-1
                           kx = kx - incx
                           if (x(jx)/=zero) then
                               ix = kx
                               l = kplus1 - j
                               if (nounit) x(jx) = x(jx)/a(kplus1,j)
                               temp = x(jx)
                               do i = j - 1,max(1,j-k),-1
                                   x(ix) = x(ix) - temp*a(l+i,j)
                                   ix = ix - incx
                               end do
                           end if
                           jx = jx - incx
                       end do
                   end if
               else
                   if (incx==1) then
                       do j = 1,n
                           if (x(j)/=zero) then
                               l = 1 - j
                               if (nounit) x(j) = x(j)/a(1,j)
                               temp = x(j)
                               do i = j + 1,min(n,j+k)
                                   x(i) = x(i) - temp*a(l+i,j)
                               end do
                           end if
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           kx = kx + incx
                           if (x(jx)/=zero) then
                               ix = kx
                               l = 1 - j
                               if (nounit) x(jx) = x(jx)/a(1,j)
                               temp = x(jx)
                               do i = j + 1,min(n,j+k)
                                   x(ix) = x(ix) - temp*a(l+i,j)
                                   ix = ix + incx
                               end do
                           end if
                           jx = jx + incx
                       end do
                   end if
               end if
           else
              ! form  x := inv( a**t)*x.
               if (stdlib_lsame(uplo,'U')) then
                   kplus1 = k + 1
                   if (incx==1) then
                       do j = 1,n
                           temp = x(j)
                           l = kplus1 - j
                           do i = max(1,j-k),j - 1
                               temp = temp - a(l+i,j)*x(i)
                           end do
                           if (nounit) temp = temp/a(kplus1,j)
                           x(j) = temp
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           temp = x(jx)
                           ix = kx
                           l = kplus1 - j
                           do i = max(1,j-k),j - 1
                               temp = temp - a(l+i,j)*x(ix)
                               ix = ix + incx
                           end do
                           if (nounit) temp = temp/a(kplus1,j)
                           x(jx) = temp
                           jx = jx + incx
                           if (j>k) kx = kx + incx
                       end do
                   end if
               else
                   if (incx==1) then
                       do j = n,1,-1
                           temp = x(j)
                           l = 1 - j
                           do i = min(n,j+k),j + 1,-1
                               temp = temp - a(l+i,j)*x(i)
                           end do
                           if (nounit) temp = temp/a(1,j)
                           x(j) = temp
                       end do
                   else
                       kx = kx + (n-1)*incx
                       jx = kx
                       do j = n,1,-1
                           temp = x(jx)
                           ix = kx
                           l = 1 - j
                           do i = min(n,j+k),j + 1,-1
                               temp = temp - a(l+i,j)*x(ix)
                               ix = ix - incx
                           end do
                           if (nounit) temp = temp/a(1,j)
                           x(jx) = temp
                           jx = jx - incx
                           if ((n-j)>=k) kx = kx - incx
                       end do
                   end if
               end if
           end if
           return
     end subroutine stdlib_stbsv

     !> STPMV:  performs one of the matrix-vector operations
     !> x := A*x,   or   x := A**T*x,
     !> where x is an n element vector and  A is an n by n unit, or non-unit,
     !> upper or lower triangular matrix, supplied in packed form.

     pure subroutine stdlib_stpmv(uplo,trans,diag,n,ap,x,incx)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, n
           character, intent(in) :: diag, trans, uplo
           ! Array Arguments 
           real(sp), intent(in) :: ap(*)
           real(sp), intent(inout) :: x(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jx, k, kk, kx
           logical(lk) :: nounit
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (.not.stdlib_lsame(trans,'N') .and. .not.stdlib_lsame(trans,'T') &
                     .and..not.stdlib_lsame(trans,'C')) then
               info = 2
           else if (.not.stdlib_lsame(diag,'U') .and. .not.stdlib_lsame(diag,'N')) then
               info = 3
           else if (n<0) then
               info = 4
           else if (incx==0) then
               info = 7
           end if
           if (info/=0) then
               call stdlib_xerbla('STPMV ',info)
               return
           end if
           ! quick return if possible.
           if (n==0) return
           nounit = stdlib_lsame(diag,'N')
           ! set up the start point in x if the increment is not unity. this
           ! will be  ( n - 1 )*incx  too small for descending loops.
           if (incx<=0) then
               kx = 1 - (n-1)*incx
           else if (incx/=1) then
               kx = 1
           end if
           ! start the operations. in this version the elements of ap are
           ! accessed sequentially with one pass through ap.
           if (stdlib_lsame(trans,'N')) then
              ! form  x:= a*x.
               if (stdlib_lsame(uplo,'U')) then
                   kk = 1
                   if (incx==1) then
                       do j = 1,n
                           if (x(j)/=zero) then
                               temp = x(j)
                               k = kk
                               do i = 1,j - 1
                                   x(i) = x(i) + temp*ap(k)
                                   k = k + 1
                               end do
                               if (nounit) x(j) = x(j)*ap(kk+j-1)
                           end if
                           kk = kk + j
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           if (x(jx)/=zero) then
                               temp = x(jx)
                               ix = kx
                               do k = kk,kk + j - 2
                                   x(ix) = x(ix) + temp*ap(k)
                                   ix = ix + incx
                               end do
                               if (nounit) x(jx) = x(jx)*ap(kk+j-1)
                           end if
                           jx = jx + incx
                           kk = kk + j
                       end do
                   end if
               else
                   kk = (n* (n+1))/2
                   if (incx==1) then
                       do j = n,1,-1
                           if (x(j)/=zero) then
                               temp = x(j)
                               k = kk
                               do i = n,j + 1,-1
                                   x(i) = x(i) + temp*ap(k)
                                   k = k - 1
                               end do
                               if (nounit) x(j) = x(j)*ap(kk-n+j)
                           end if
                           kk = kk - (n-j+1)
                       end do
                   else
                       kx = kx + (n-1)*incx
                       jx = kx
                       do j = n,1,-1
                           if (x(jx)/=zero) then
                               temp = x(jx)
                               ix = kx
                               do k = kk,kk - (n- (j+1)),-1
                                   x(ix) = x(ix) + temp*ap(k)
                                   ix = ix - incx
                               end do
                               if (nounit) x(jx) = x(jx)*ap(kk-n+j)
                           end if
                           jx = jx - incx
                           kk = kk - (n-j+1)
                       end do
                   end if
               end if
           else
              ! form  x := a**t*x.
               if (stdlib_lsame(uplo,'U')) then
                   kk = (n* (n+1))/2
                   if (incx==1) then
                       do j = n,1,-1
                           temp = x(j)
                           if (nounit) temp = temp*ap(kk)
                           k = kk - 1
                           do i = j - 1,1,-1
                               temp = temp + ap(k)*x(i)
                               k = k - 1
                           end do
                           x(j) = temp
                           kk = kk - j
                       end do
                   else
                       jx = kx + (n-1)*incx
                       do j = n,1,-1
                           temp = x(jx)
                           ix = jx
                           if (nounit) temp = temp*ap(kk)
                           do k = kk - 1,kk - j + 1,-1
                               ix = ix - incx
                               temp = temp + ap(k)*x(ix)
                           end do
                           x(jx) = temp
                           jx = jx - incx
                           kk = kk - j
                       end do
                   end if
               else
                   kk = 1
                   if (incx==1) then
                       do j = 1,n
                           temp = x(j)
                           if (nounit) temp = temp*ap(kk)
                           k = kk + 1
                           do i = j + 1,n
                               temp = temp + ap(k)*x(i)
                               k = k + 1
                           end do
                           x(j) = temp
                           kk = kk + (n-j+1)
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           temp = x(jx)
                           ix = jx
                           if (nounit) temp = temp*ap(kk)
                           do k = kk + 1,kk + n - j
                               ix = ix + incx
                               temp = temp + ap(k)*x(ix)
                           end do
                           x(jx) = temp
                           jx = jx + incx
                           kk = kk + (n-j+1)
                       end do
                   end if
               end if
           end if
           return
     end subroutine stdlib_stpmv

     !> STPSV:  solves one of the systems of equations
     !> A*x = b,   or   A**T*x = b,
     !> where b and x are n element vectors and A is an n by n unit, or
     !> non-unit, upper or lower triangular matrix, supplied in packed form.
     !> No test for singularity or near-singularity is included in this
     !> routine. Such tests must be performed before calling this routine.

     pure subroutine stdlib_stpsv(uplo,trans,diag,n,ap,x,incx)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, n
           character, intent(in) :: diag, trans, uplo
           ! Array Arguments 
           real(sp), intent(in) :: ap(*)
           real(sp), intent(inout) :: x(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jx, k, kk, kx
           logical(lk) :: nounit
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (.not.stdlib_lsame(trans,'N') .and. .not.stdlib_lsame(trans,'T') &
                     .and..not.stdlib_lsame(trans,'C')) then
               info = 2
           else if (.not.stdlib_lsame(diag,'U') .and. .not.stdlib_lsame(diag,'N')) then
               info = 3
           else if (n<0) then
               info = 4
           else if (incx==0) then
               info = 7
           end if
           if (info/=0) then
               call stdlib_xerbla('STPSV ',info)
               return
           end if
           ! quick return if possible.
           if (n==0) return
           nounit = stdlib_lsame(diag,'N')
           ! set up the start point in x if the increment is not unity. this
           ! will be  ( n - 1 )*incx  too small for descending loops.
           if (incx<=0) then
               kx = 1 - (n-1)*incx
           else if (incx/=1) then
               kx = 1
           end if
           ! start the operations. in this version the elements of ap are
           ! accessed sequentially with one pass through ap.
           if (stdlib_lsame(trans,'N')) then
              ! form  x := inv( a )*x.
               if (stdlib_lsame(uplo,'U')) then
                   kk = (n* (n+1))/2
                   if (incx==1) then
                       do j = n,1,-1
                           if (x(j)/=zero) then
                               if (nounit) x(j) = x(j)/ap(kk)
                               temp = x(j)
                               k = kk - 1
                               do i = j - 1,1,-1
                                   x(i) = x(i) - temp*ap(k)
                                   k = k - 1
                               end do
                           end if
                           kk = kk - j
                       end do
                   else
                       jx = kx + (n-1)*incx
                       do j = n,1,-1
                           if (x(jx)/=zero) then
                               if (nounit) x(jx) = x(jx)/ap(kk)
                               temp = x(jx)
                               ix = jx
                               do k = kk - 1,kk - j + 1,-1
                                   ix = ix - incx
                                   x(ix) = x(ix) - temp*ap(k)
                               end do
                           end if
                           jx = jx - incx
                           kk = kk - j
                       end do
                   end if
               else
                   kk = 1
                   if (incx==1) then
                       do j = 1,n
                           if (x(j)/=zero) then
                               if (nounit) x(j) = x(j)/ap(kk)
                               temp = x(j)
                               k = kk + 1
                               do i = j + 1,n
                                   x(i) = x(i) - temp*ap(k)
                                   k = k + 1
                               end do
                           end if
                           kk = kk + (n-j+1)
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           if (x(jx)/=zero) then
                               if (nounit) x(jx) = x(jx)/ap(kk)
                               temp = x(jx)
                               ix = jx
                               do k = kk + 1,kk + n - j
                                   ix = ix + incx
                                   x(ix) = x(ix) - temp*ap(k)
                               end do
                           end if
                           jx = jx + incx
                           kk = kk + (n-j+1)
                       end do
                   end if
               end if
           else
              ! form  x := inv( a**t )*x.
               if (stdlib_lsame(uplo,'U')) then
                   kk = 1
                   if (incx==1) then
                       do j = 1,n
                           temp = x(j)
                           k = kk
                           do i = 1,j - 1
                               temp = temp - ap(k)*x(i)
                               k = k + 1
                           end do
                           if (nounit) temp = temp/ap(kk+j-1)
                           x(j) = temp
                           kk = kk + j
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           temp = x(jx)
                           ix = kx
                           do k = kk,kk + j - 2
                               temp = temp - ap(k)*x(ix)
                               ix = ix + incx
                           end do
                           if (nounit) temp = temp/ap(kk+j-1)
                           x(jx) = temp
                           jx = jx + incx
                           kk = kk + j
                       end do
                   end if
               else
                   kk = (n* (n+1))/2
                   if (incx==1) then
                       do j = n,1,-1
                           temp = x(j)
                           k = kk
                           do i = n,j + 1,-1
                               temp = temp - ap(k)*x(i)
                               k = k - 1
                           end do
                           if (nounit) temp = temp/ap(kk-n+j)
                           x(j) = temp
                           kk = kk - (n-j+1)
                       end do
                   else
                       kx = kx + (n-1)*incx
                       jx = kx
                       do j = n,1,-1
                           temp = x(jx)
                           ix = kx
                           do k = kk,kk - (n- (j+1)),-1
                               temp = temp - ap(k)*x(ix)
                               ix = ix - incx
                           end do
                           if (nounit) temp = temp/ap(kk-n+j)
                           x(jx) = temp
                           jx = jx - incx
                           kk = kk - (n-j+1)
                       end do
                   end if
               end if
           end if
           return
     end subroutine stdlib_stpsv

     !> STRMM:  performs one of the matrix-matrix operations
     !> B := alpha*op( A )*B,   or   B := alpha*B*op( A ),
     !> where  alpha  is a scalar,  B  is an m by n matrix,  A  is a unit, or
     !> non-unit,  upper or lower triangular matrix  and  op( A )  is one  of
     !> op( A ) = A   or   op( A ) = A**T.

     pure subroutine stdlib_strmm(side,uplo,transa,diag,m,n,alpha,a,lda,b,ldb)
        ! -- reference blas level3 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha
           integer(ilp), intent(in) :: lda, ldb, m, n
           character, intent(in) :: diag, side, transa, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*)
           real(sp), intent(inout) :: b(ldb,*)
        ! =====================================================================
           ! Intrinsic Functions 
           intrinsic :: max
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, j, k, nrowa
           logical(lk) :: lside, nounit, upper
           
           ! test the input parameters.
           lside = stdlib_lsame(side,'L')
           if (lside) then
               nrowa = m
           else
               nrowa = n
           end if
           nounit = stdlib_lsame(diag,'N')
           upper = stdlib_lsame(uplo,'U')
           info = 0
           if ((.not.lside) .and. (.not.stdlib_lsame(side,'R'))) then
               info = 1
           else if ((.not.upper) .and. (.not.stdlib_lsame(uplo,'L'))) then
               info = 2
           else if ((.not.stdlib_lsame(transa,'N')) .and.(.not.stdlib_lsame(transa,'T')) .and.(&
                     .not.stdlib_lsame(transa,'C'))) then
               info = 3
           else if ((.not.stdlib_lsame(diag,'U')) .and. (.not.stdlib_lsame(diag,'N'))) &
                     then
               info = 4
           else if (m<0) then
               info = 5
           else if (n<0) then
               info = 6
           else if (lda<max(1,nrowa)) then
               info = 9
           else if (ldb<max(1,m)) then
               info = 11
           end if
           if (info/=0) then
               call stdlib_xerbla('STRMM ',info)
               return
           end if
           ! quick return if possible.
           if (m==0 .or. n==0) return
           ! and when  alpha.eq.zero.
           if (alpha==zero) then
               do j = 1,n
                   do i = 1,m
                       b(i,j) = zero
                   end do
               end do
               return
           end if
           ! start the operations.
           if (lside) then
               if (stdlib_lsame(transa,'N')) then
                 ! form  b := alpha*a*b.
                   if (upper) then
                       do j = 1,n
                           do k = 1,m
                               if (b(k,j)/=zero) then
                                   temp = alpha*b(k,j)
                                   do i = 1,k - 1
                                       b(i,j) = b(i,j) + temp*a(i,k)
                                   end do
                                   if (nounit) temp = temp*a(k,k)
                                   b(k,j) = temp
                               end if
                           end do
                       end do
                   else
                       do j = 1,n
                           do k = m,1,-1
                               if (b(k,j)/=zero) then
                                   temp = alpha*b(k,j)
                                   b(k,j) = temp
                                   if (nounit) b(k,j) = b(k,j)*a(k,k)
                                   do i = k + 1,m
                                       b(i,j) = b(i,j) + temp*a(i,k)
                                   end do
                               end if
                           end do
                       end do
                   end if
               else
                 ! form  b := alpha*a**t*b.
                   if (upper) then
                       do j = 1,n
                           do i = m,1,-1
                               temp = b(i,j)
                               if (nounit) temp = temp*a(i,i)
                               do k = 1,i - 1
                                   temp = temp + a(k,i)*b(k,j)
                               end do
                               b(i,j) = alpha*temp
                           end do
                       end do
                   else
                       do j = 1,n
                           do i = 1,m
                               temp = b(i,j)
                               if (nounit) temp = temp*a(i,i)
                               do k = i + 1,m
                                   temp = temp + a(k,i)*b(k,j)
                               end do
                               b(i,j) = alpha*temp
                           end do
                       end do
                   end if
               end if
           else
               if (stdlib_lsame(transa,'N')) then
                 ! form  b := alpha*b*a.
                   if (upper) then
                       do j = n,1,-1
                           temp = alpha
                           if (nounit) temp = temp*a(j,j)
                           do i = 1,m
                               b(i,j) = temp*b(i,j)
                           end do
                           do k = 1,j - 1
                               if (a(k,j)/=zero) then
                                   temp = alpha*a(k,j)
                                   do i = 1,m
                                       b(i,j) = b(i,j) + temp*b(i,k)
                                   end do
                               end if
                           end do
                       end do
                   else
                       do j = 1,n
                           temp = alpha
                           if (nounit) temp = temp*a(j,j)
                           do i = 1,m
                               b(i,j) = temp*b(i,j)
                           end do
                           do k = j + 1,n
                               if (a(k,j)/=zero) then
                                   temp = alpha*a(k,j)
                                   do i = 1,m
                                       b(i,j) = b(i,j) + temp*b(i,k)
                                   end do
                               end if
                           end do
                       end do
                   end if
               else
                 ! form  b := alpha*b*a**t.
                   if (upper) then
                       do k = 1,n
                           do j = 1,k - 1
                               if (a(j,k)/=zero) then
                                   temp = alpha*a(j,k)
                                   do i = 1,m
                                       b(i,j) = b(i,j) + temp*b(i,k)
                                   end do
                               end if
                           end do
                           temp = alpha
                           if (nounit) temp = temp*a(k,k)
                           if (temp/=one) then
                               do i = 1,m
                                   b(i,k) = temp*b(i,k)
                               end do
                           end if
                       end do
                   else
                       do k = n,1,-1
                           do j = k + 1,n
                               if (a(j,k)/=zero) then
                                   temp = alpha*a(j,k)
                                   do i = 1,m
                                       b(i,j) = b(i,j) + temp*b(i,k)
                                   end do
                               end if
                           end do
                           temp = alpha
                           if (nounit) temp = temp*a(k,k)
                           if (temp/=one) then
                               do i = 1,m
                                   b(i,k) = temp*b(i,k)
                               end do
                           end if
                       end do
                   end if
               end if
           end if
           return
     end subroutine stdlib_strmm

     !> STRMV:  performs one of the matrix-vector operations
     !> x := A*x,   or   x := A**T*x,
     !> where x is an n element vector and  A is an n by n unit, or non-unit,
     !> upper or lower triangular matrix.

     pure subroutine stdlib_strmv(uplo,trans,diag,n,a,lda,x,incx)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, lda, n
           character, intent(in) :: diag, trans, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*)
           real(sp), intent(inout) :: x(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jx, kx
           logical(lk) :: nounit
           ! Intrinsic Functions 
           intrinsic :: max
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (.not.stdlib_lsame(trans,'N') .and. .not.stdlib_lsame(trans,'T') &
                     .and..not.stdlib_lsame(trans,'C')) then
               info = 2
           else if (.not.stdlib_lsame(diag,'U') .and. .not.stdlib_lsame(diag,'N')) then
               info = 3
           else if (n<0) then
               info = 4
           else if (lda<max(1,n)) then
               info = 6
           else if (incx==0) then
               info = 8
           end if
           if (info/=0) then
               call stdlib_xerbla('STRMV ',info)
               return
           end if
           ! quick return if possible.
           if (n==0) return
           nounit = stdlib_lsame(diag,'N')
           ! set up the start point in x if the increment is not unity. this
           ! will be  ( n - 1 )*incx  too small for descending loops.
           if (incx<=0) then
               kx = 1 - (n-1)*incx
           else if (incx/=1) then
               kx = 1
           end if
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through a.
           if (stdlib_lsame(trans,'N')) then
              ! form  x := a*x.
               if (stdlib_lsame(uplo,'U')) then
                   if (incx==1) then
                       do j = 1,n
                           if (x(j)/=zero) then
                               temp = x(j)
                               do i = 1,j - 1
                                   x(i) = x(i) + temp*a(i,j)
                               end do
                               if (nounit) x(j) = x(j)*a(j,j)
                           end if
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           if (x(jx)/=zero) then
                               temp = x(jx)
                               ix = kx
                               do i = 1,j - 1
                                   x(ix) = x(ix) + temp*a(i,j)
                                   ix = ix + incx
                               end do
                               if (nounit) x(jx) = x(jx)*a(j,j)
                           end if
                           jx = jx + incx
                       end do
                   end if
               else
                   if (incx==1) then
                       do j = n,1,-1
                           if (x(j)/=zero) then
                               temp = x(j)
                               do i = n,j + 1,-1
                                   x(i) = x(i) + temp*a(i,j)
                               end do
                               if (nounit) x(j) = x(j)*a(j,j)
                           end if
                       end do
                   else
                       kx = kx + (n-1)*incx
                       jx = kx
                       do j = n,1,-1
                           if (x(jx)/=zero) then
                               temp = x(jx)
                               ix = kx
                               do i = n,j + 1,-1
                                   x(ix) = x(ix) + temp*a(i,j)
                                   ix = ix - incx
                               end do
                               if (nounit) x(jx) = x(jx)*a(j,j)
                           end if
                           jx = jx - incx
                       end do
                   end if
               end if
           else
              ! form  x := a**t*x.
               if (stdlib_lsame(uplo,'U')) then
                   if (incx==1) then
                       do j = n,1,-1
                           temp = x(j)
                           if (nounit) temp = temp*a(j,j)
                           do i = j - 1,1,-1
                               temp = temp + a(i,j)*x(i)
                           end do
                           x(j) = temp
                       end do
                   else
                       jx = kx + (n-1)*incx
                       do j = n,1,-1
                           temp = x(jx)
                           ix = jx
                           if (nounit) temp = temp*a(j,j)
                           do i = j - 1,1,-1
                               ix = ix - incx
                               temp = temp + a(i,j)*x(ix)
                           end do
                           x(jx) = temp
                           jx = jx - incx
                       end do
                   end if
               else
                   if (incx==1) then
                       do j = 1,n
                           temp = x(j)
                           if (nounit) temp = temp*a(j,j)
                           do i = j + 1,n
                               temp = temp + a(i,j)*x(i)
                           end do
                           x(j) = temp
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           temp = x(jx)
                           ix = jx
                           if (nounit) temp = temp*a(j,j)
                           do i = j + 1,n
                               ix = ix + incx
                               temp = temp + a(i,j)*x(ix)
                           end do
                           x(jx) = temp
                           jx = jx + incx
                       end do
                   end if
               end if
           end if
           return
     end subroutine stdlib_strmv

     !> STRSM:  solves one of the matrix equations
     !> op( A )*X = alpha*B,   or   X*op( A ) = alpha*B,
     !> where alpha is a scalar, X and B are m by n matrices, A is a unit, or
     !> non-unit,  upper or lower triangular matrix  and  op( A )  is one  of
     !> op( A ) = A   or   op( A ) = A**T.
     !> The matrix X is overwritten on B.

     pure subroutine stdlib_strsm(side,uplo,transa,diag,m,n,alpha,a,lda,b,ldb)
        ! -- reference blas level3 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           real(sp), intent(in) :: alpha
           integer(ilp), intent(in) :: lda, ldb, m, n
           character, intent(in) :: diag, side, transa, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*)
           real(sp), intent(inout) :: b(ldb,*)
        ! =====================================================================
           ! Intrinsic Functions 
           intrinsic :: max
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, j, k, nrowa
           logical(lk) :: lside, nounit, upper
           
           ! test the input parameters.
           lside = stdlib_lsame(side,'L')
           if (lside) then
               nrowa = m
           else
               nrowa = n
           end if
           nounit = stdlib_lsame(diag,'N')
           upper = stdlib_lsame(uplo,'U')
           info = 0
           if ((.not.lside) .and. (.not.stdlib_lsame(side,'R'))) then
               info = 1
           else if ((.not.upper) .and. (.not.stdlib_lsame(uplo,'L'))) then
               info = 2
           else if ((.not.stdlib_lsame(transa,'N')) .and.(.not.stdlib_lsame(transa,'T')) .and.(&
                     .not.stdlib_lsame(transa,'C'))) then
               info = 3
           else if ((.not.stdlib_lsame(diag,'U')) .and. (.not.stdlib_lsame(diag,'N'))) &
                     then
               info = 4
           else if (m<0) then
               info = 5
           else if (n<0) then
               info = 6
           else if (lda<max(1,nrowa)) then
               info = 9
           else if (ldb<max(1,m)) then
               info = 11
           end if
           if (info/=0) then
               call stdlib_xerbla('STRSM ',info)
               return
           end if
           ! quick return if possible.
           if (m==0 .or. n==0) return
           ! and when  alpha.eq.zero.
           if (alpha==zero) then
               do j = 1,n
                   do i = 1,m
                       b(i,j) = zero
                   end do
               end do
               return
           end if
           ! start the operations.
           if (lside) then
               if (stdlib_lsame(transa,'N')) then
                 ! form  b := alpha*inv( a )*b.
                   if (upper) then
                       do j = 1,n
                           if (alpha/=one) then
                               do i = 1,m
                                   b(i,j) = alpha*b(i,j)
                               end do
                           end if
                           do k = m,1,-1
                               if (b(k,j)/=zero) then
                                   if (nounit) b(k,j) = b(k,j)/a(k,k)
                                   do i = 1,k - 1
                                       b(i,j) = b(i,j) - b(k,j)*a(i,k)
                                   end do
                               end if
                           end do
                       end do
                   else
                       do j = 1,n
                           if (alpha/=one) then
                               do i = 1,m
                                   b(i,j) = alpha*b(i,j)
                               end do
                           end if
                           do k = 1,m
                               if (b(k,j)/=zero) then
                                   if (nounit) b(k,j) = b(k,j)/a(k,k)
                                   do i = k + 1,m
                                       b(i,j) = b(i,j) - b(k,j)*a(i,k)
                                   end do
                               end if
                           end do
                       end do
                   end if
               else
                 ! form  b := alpha*inv( a**t )*b.
                   if (upper) then
                       do j = 1,n
                           do i = 1,m
                               temp = alpha*b(i,j)
                               do k = 1,i - 1
                                   temp = temp - a(k,i)*b(k,j)
                               end do
                               if (nounit) temp = temp/a(i,i)
                               b(i,j) = temp
                           end do
                       end do
                   else
                       do j = 1,n
                           do i = m,1,-1
                               temp = alpha*b(i,j)
                               do k = i + 1,m
                                   temp = temp - a(k,i)*b(k,j)
                               end do
                               if (nounit) temp = temp/a(i,i)
                               b(i,j) = temp
                           end do
                       end do
                   end if
               end if
           else
               if (stdlib_lsame(transa,'N')) then
                 ! form  b := alpha*b*inv( a ).
                   if (upper) then
                       do j = 1,n
                           if (alpha/=one) then
                               do i = 1,m
                                   b(i,j) = alpha*b(i,j)
                               end do
                           end if
                           do k = 1,j - 1
                               if (a(k,j)/=zero) then
                                   do i = 1,m
                                       b(i,j) = b(i,j) - a(k,j)*b(i,k)
                                   end do
                               end if
                           end do
                           if (nounit) then
                               temp = one/a(j,j)
                               do i = 1,m
                                   b(i,j) = temp*b(i,j)
                               end do
                           end if
                       end do
                   else
                       do j = n,1,-1
                           if (alpha/=one) then
                               do i = 1,m
                                   b(i,j) = alpha*b(i,j)
                               end do
                           end if
                           do k = j + 1,n
                               if (a(k,j)/=zero) then
                                   do i = 1,m
                                       b(i,j) = b(i,j) - a(k,j)*b(i,k)
                                   end do
                               end if
                           end do
                           if (nounit) then
                               temp = one/a(j,j)
                               do i = 1,m
                                   b(i,j) = temp*b(i,j)
                               end do
                           end if
                       end do
                   end if
               else
                 ! form  b := alpha*b*inv( a**t ).
                   if (upper) then
                       do k = n,1,-1
                           if (nounit) then
                               temp = one/a(k,k)
                               do i = 1,m
                                   b(i,k) = temp*b(i,k)
                               end do
                           end if
                           do j = 1,k - 1
                               if (a(j,k)/=zero) then
                                   temp = a(j,k)
                                   do i = 1,m
                                       b(i,j) = b(i,j) - temp*b(i,k)
                                   end do
                               end if
                           end do
                           if (alpha/=one) then
                               do i = 1,m
                                   b(i,k) = alpha*b(i,k)
                               end do
                           end if
                       end do
                   else
                       do k = 1,n
                           if (nounit) then
                               temp = one/a(k,k)
                               do i = 1,m
                                   b(i,k) = temp*b(i,k)
                               end do
                           end if
                           do j = k + 1,n
                               if (a(j,k)/=zero) then
                                   temp = a(j,k)
                                   do i = 1,m
                                       b(i,j) = b(i,j) - temp*b(i,k)
                                   end do
                               end if
                           end do
                           if (alpha/=one) then
                               do i = 1,m
                                   b(i,k) = alpha*b(i,k)
                               end do
                           end if
                       end do
                   end if
               end if
           end if
           return
     end subroutine stdlib_strsm

     !> STRSV:  solves one of the systems of equations
     !> A*x = b,   or   A**T*x = b,
     !> where b and x are n element vectors and A is an n by n unit, or
     !> non-unit, upper or lower triangular matrix.
     !> No test for singularity or near-singularity is included in this
     !> routine. Such tests must be performed before calling this routine.

     pure subroutine stdlib_strsv(uplo,trans,diag,n,a,lda,x,incx)
        ! -- reference blas level2 routine --
        ! -- reference blas is a software package provided by univ. of tennessee,    --
        ! -- univ. of california berkeley, univ. of colorado denver and nag ltd..--
           ! Scalar Arguments 
           integer(ilp), intent(in) :: incx, lda, n
           character, intent(in) :: diag, trans, uplo
           ! Array Arguments 
           real(sp), intent(in) :: a(lda,*)
           real(sp), intent(inout) :: x(*)
        ! =====================================================================
           
           ! Local Scalars 
           real(sp) :: temp
           integer(ilp) :: i, info, ix, j, jx, kx
           logical(lk) :: nounit
           ! Intrinsic Functions 
           intrinsic :: max
           ! test the input parameters.
           info = 0
           if (.not.stdlib_lsame(uplo,'U') .and. .not.stdlib_lsame(uplo,'L')) then
               info = 1
           else if (.not.stdlib_lsame(trans,'N') .and. .not.stdlib_lsame(trans,'T') &
                     .and..not.stdlib_lsame(trans,'C')) then
               info = 2
           else if (.not.stdlib_lsame(diag,'U') .and. .not.stdlib_lsame(diag,'N')) then
               info = 3
           else if (n<0) then
               info = 4
           else if (lda<max(1,n)) then
               info = 6
           else if (incx==0) then
               info = 8
           end if
           if (info/=0) then
               call stdlib_xerbla('STRSV ',info)
               return
           end if
           ! quick return if possible.
           if (n==0) return
           nounit = stdlib_lsame(diag,'N')
           ! set up the start point in x if the increment is not unity. this
           ! will be  ( n - 1 )*incx  too small for descending loops.
           if (incx<=0) then
               kx = 1 - (n-1)*incx
           else if (incx/=1) then
               kx = 1
           end if
           ! start the operations. in this version the elements of a are
           ! accessed sequentially with one pass through a.
           if (stdlib_lsame(trans,'N')) then
              ! form  x := inv( a )*x.
               if (stdlib_lsame(uplo,'U')) then
                   if (incx==1) then
                       do j = n,1,-1
                           if (x(j)/=zero) then
                               if (nounit) x(j) = x(j)/a(j,j)
                               temp = x(j)
                               do i = j - 1,1,-1
                                   x(i) = x(i) - temp*a(i,j)
                               end do
                           end if
                       end do
                   else
                       jx = kx + (n-1)*incx
                       do j = n,1,-1
                           if (x(jx)/=zero) then
                               if (nounit) x(jx) = x(jx)/a(j,j)
                               temp = x(jx)
                               ix = jx
                               do i = j - 1,1,-1
                                   ix = ix - incx
                                   x(ix) = x(ix) - temp*a(i,j)
                               end do
                           end if
                           jx = jx - incx
                       end do
                   end if
               else
                   if (incx==1) then
                       do j = 1,n
                           if (x(j)/=zero) then
                               if (nounit) x(j) = x(j)/a(j,j)
                               temp = x(j)
                               do i = j + 1,n
                                   x(i) = x(i) - temp*a(i,j)
                               end do
                           end if
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           if (x(jx)/=zero) then
                               if (nounit) x(jx) = x(jx)/a(j,j)
                               temp = x(jx)
                               ix = jx
                               do i = j + 1,n
                                   ix = ix + incx
                                   x(ix) = x(ix) - temp*a(i,j)
                               end do
                           end if
                           jx = jx + incx
                       end do
                   end if
               end if
           else
              ! form  x := inv( a**t )*x.
               if (stdlib_lsame(uplo,'U')) then
                   if (incx==1) then
                       do j = 1,n
                           temp = x(j)
                           do i = 1,j - 1
                               temp = temp - a(i,j)*x(i)
                           end do
                           if (nounit) temp = temp/a(j,j)
                           x(j) = temp
                       end do
                   else
                       jx = kx
                       do j = 1,n
                           temp = x(jx)
                           ix = kx
                           do i = 1,j - 1
                               temp = temp - a(i,j)*x(ix)
                               ix = ix + incx
                           end do
                           if (nounit) temp = temp/a(j,j)
                           x(jx) = temp
                           jx = jx + incx
                       end do
                   end if
               else
                   if (incx==1) then
                       do j = n,1,-1
                           temp = x(j)
                           do i = n,j + 1,-1
                               temp = temp - a(i,j)*x(i)
                           end do
                           if (nounit) temp = temp/a(j,j)
                           x(j) = temp
                       end do
                   else
                       kx = kx + (n-1)*incx
                       jx = kx
                       do j = n,1,-1
                           temp = x(jx)
                           ix = kx
                           do i = n,j + 1,-1
                               temp = temp - a(i,j)*x(ix)
                               ix = ix - incx
                           end do
                           if (nounit) temp = temp/a(j,j)
                           x(jx) = temp
                           jx = jx - incx
                       end do
                   end if
               end if
           end if
           return
     end subroutine stdlib_strsv



end module stdlib_linalg_blas_s
