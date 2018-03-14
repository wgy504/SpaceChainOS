;/*********************************************************************************************************
;**
;**                                    �й�������Դ��֯
;**
;**                                   Ƕ��ʽʵʱ����ϵͳ
;**
;**                                       SylixOS(TM)
;**
;**                               Copyright  All Rights Reserved
;**
;**--------------�ļ���Ϣ--------------------------------------------------------------------------------
;**
;** ��   ��   ��: sparExcAsm.S
;**
;** ��   ��   ��: Xu.Guizhou (�����)
;**
;** �ļ���������: 2017 �� 05 �� 15 ��
;**
;** ��        ��: SPARC ��ϵ�����쳣����.
;*********************************************************************************************************/

#ifndef ASSEMBLY
#define ASSEMBLY 1
#endif

#include <arch/assembler.h>
#include <config/kernel/kernel_cfg.h>
#include <config/mp/mp_cfg.h>
#include "sparcContextAsm.h"

    FILE_BEGIN()
    
    IMPORT_LABEL(API_ThreadTcbInter)
    IMPORT_LABEL(API_InterStackBaseGet)
    IMPORT_LABEL(API_InterEnter)
    IMPORT_LABEL(API_InterExit)
    
    IMPORT_LABEL(archMpCur)
    IMPORT_LABEL(archCtxLoad)
    IMPORT_LABEL(_G_ulCpu)
    IMPORT_LABEL(_G_ulIntNesting)
    IMPORT_LABEL(_G_ulIntSafeStack)

    IMPORT_LABEL(archDataStoreErrHandle)
    IMPORT_LABEL(archInstAccessMmuMissHandle)
    IMPORT_LABEL(archInstAccessErrHandle)
    IMPORT_LABEL(archRRegAccessErrHandle)
    IMPORT_LABEL(archInstAccessExcHandle)
    IMPORT_LABEL(archPrivInstHandle)
    IMPORT_LABEL(archIllegalInstHandle)
    IMPORT_LABEL(archFpDisableHandle)
    IMPORT_LABEL(archCpDisableHandle)
    IMPORT_LABEL(archUnimplFlushHandle)
    IMPORT_LABEL(archWatchPointDectectHandle)
    IMPORT_LABEL(archMemAddrNoAlignHandle)
    IMPORT_LABEL(archFpExcHandle)
    IMPORT_LABEL(archCpExcHandle)
    IMPORT_LABEL(archDataAccessErrHandle)
    IMPORT_LABEL(archDataAccessMmuMissHandle)
    IMPORT_LABEL(archDataAccessExcHandle)
    IMPORT_LABEL(archTagOverFlowHandle)
    IMPORT_LABEL(archDivZeroHandle)
    IMPORT_LABEL(archTrapInstHandle)
    IMPORT_LABEL(bspIntHandle)

    EXPORT_LABEL(archDataStoreErrEntry)
    EXPORT_LABEL(archInstAccessMmuMissEntry)
    EXPORT_LABEL(archInstAccessErrEntry)
    EXPORT_LABEL(archRRegAccessErrEntry)
    EXPORT_LABEL(archInstAccessExcEntry)
    EXPORT_LABEL(archPrivInstEntry)
    EXPORT_LABEL(archIllegalInstEntry)
    EXPORT_LABEL(archFpDisableEntry)
    EXPORT_LABEL(archCpDisableEntry)
    EXPORT_LABEL(archUnimplFlushEntry)
    EXPORT_LABEL(archWatchPointDectectEntry)
    EXPORT_LABEL(archMemAddrNoAlignEntry)
    EXPORT_LABEL(archFpExcEntry)
    EXPORT_LABEL(archCpExcEntry)
    EXPORT_LABEL(archDataAccessErrEntry)
    EXPORT_LABEL(archDataAccessMmuMissEntry)
    EXPORT_LABEL(archDataAccessExcEntry)
    EXPORT_LABEL(archTagOverFlowEntry)
    EXPORT_LABEL(archDivZeroEntry)
    EXPORT_LABEL(archTrapInstEntry)
    EXPORT_LABEL(archIntEntry)

;/*********************************************************************************************************
;  �����Ĵ���
;*********************************************************************************************************/

#define PSR_ARG_REG         l0
#define PC_ARG_REG          l1
#define NPC_ARG_REG         l2
#define TRAP_TYPE_ARG_REG   l3

;/*********************************************************************************************************
;  SPARC �쳣��ں�
;   l0 = PSR
;   l1 = PC
;   l2 = nPC
;   l3 = trap type
;*********************************************************************************************************/

MACRO_DEF(SPARC_TRAP_ENTRY handle arg)
    ST      %l1  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_PC]            ;/*  ���� PC                     */
    ST      %l2  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_NPC]           ;/*  ���� Next PC                */

    STD     %i0  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_OUTPUT(0)]     ;/*  ��������Ĵ���              */
    SPARC_B2BST_NOP
    STD     %i2  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_OUTPUT(2)]
    SPARC_B2BST_NOP
    STD     %i4  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_OUTPUT(4)]
    SPARC_B2BST_NOP
    STD     %i6  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_OUTPUT(6)]     ;/*  �����쳣ǰ�� %sp            */
    SPARC_B2BST_NOP

    ST      %g1  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_GLOBAL(1)]     ;/*  ����ȫ�ּĴ���(���� %g0)    */
    STD     %g2  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_GLOBAL(2)]
    SPARC_B2BST_NOP
    STD     %g4  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_GLOBAL(4)]
    SPARC_B2BST_NOP
    STD     %g6  , [%i6 - ASM_REG_STACK_FRAME_SIZE + REG_GLOBAL(6)]

    MOV     %\arg , %g7

    RESTORE                                                             ;/*  �ص��쳣ǰ�ļĴ�������      */

    ;/*
    ; * ���� CPU ������
    ; */
    SUB     %sp  , ASM_REG_STACK_FRAME_SIZE , %g6                       ;/*  ����ջ�ռ�                  */

    STD     %l0  , [%g6 + REG_LOCAL(0)]                                 ;/*  ���汾�ؼĴ���              */
    SPARC_B2BST_NOP
    STD     %l2  , [%g6 + REG_LOCAL(2)]
    SPARC_B2BST_NOP
    STD     %l4  , [%g6 + REG_LOCAL(4)]
    SPARC_B2BST_NOP
    STD     %l6  , [%g6 + REG_LOCAL(6)]
    SPARC_B2BST_NOP

    STD     %i0  , [%g6 + REG_INPUT(0)]                                 ;/*  ��������Ĵ���              */
    SPARC_B2BST_NOP
    STD     %i2  , [%g6 + REG_INPUT(2)]
    SPARC_B2BST_NOP
    STD     %i4  , [%g6 + REG_INPUT(4)]
    SPARC_B2BST_NOP
    STD     %i6  , [%g6 + REG_INPUT(6)]

    RD      %psr , %l0                                                  ;/*  ����ص��쳣ǰ�ļĴ�������  */
    ST      %l0  , [%g6 + REG_PSR]                                      ;/*  ������ȷ���� PSR ״̬�Ĵ��� */

    RD      %y   , %l0
    ST      %l0  , [%g6 + REG_Y]                                        ;/*  ���� Y �Ĵ���               */

    ;/*
    ; *  if (API_InterEnter() == 1) {
    ; *      current stack = SP;
    ; *      SP = interrupt stack;
    ; *  }
    ; */
    ;/*
    ; * �ж�Ƕ�׼�����һ
    ; */
    SET     _G_ulIntNesting , %l0                                       ;/*  %l0 = _G_ulIntNesting       */

#if LW_CFG_SMP_EN > 0
    READ_CPUID(%l2)                                                     ;/*  %l2 = CPU_ID                */
    SLL     %l2   , 2   , %l2                                           ;/*  %l2 = CPU_ID * 4            */
    ADD     %l2   , %l0 , %l0                                           ;/*  %l0 = &nesting[CPU_ID]      */
#endif

    LD      [%l0] , %l1                                                 ;/*  %l1 = �ж�Ƕ�׼�����ַ      */
    LD      [%l1] , %l0                                                 ;/*  %l0 = �ж�Ƕ�׼���          */

    ADD     %l0 , 1 , %g1                                               ;/*  %g1 = �ж�Ƕ�׼�����һ!!!   */
    ST      %g1 , [%l1]                                                 ;/*  �洢��ȥ                    */

    CMP     %g1 , 1
    BNE     1f
    NOP

    SET     _G_ulCpu , %l0                                              ;/*  %l0 = _G_ulCpu              */

#if LW_CFG_SMP_EN > 0
    ADD     %l2 , %l0 , %l0                                             ;/*  %l0 = &_G_ulCpu[CPU_ID]     */
#endif

    LD      [%l0] , %l1                                                 ;/*  %l1 = ��ǰ CPU �ṹָ��     */
    LD      [%l1] , %l0                                                 ;/*  %l0 = ��ǰ TCB �ṹָ��     */

    ST      %g6  , [%l0]                                                ;/*  ���浱ǰ��ջָ�뵽��ǰ TCB  */

1:
    ;/*
    ; * %g1 = ��ǰ�ж�Ƕ�׼���, ��֤ flush ���ں�, ����ͨ�� %g1 ��ȡ��ǰ�ж�Ƕ�׼���
    ; * %g6 = ��ǰ %sp, ��֤ flush ���ں�, ����ͨ�� %g6 ��ȡ��ǰջָ��
    ; * %g7 = trap type �� PC
    ; */

    FLUSH_WINDOWS                                                       ;/*  flush ����                  */

    CMP     %g1 , 1
    BE      2f
    NOP

    SUB     %g6 , ASM_STACK_FRAME_SIZE , %sp                            ;/*  ����ջ�ռ�                  */
    B       3f
    ANDN    %sp , (ARCH_STK_ALIGN_SIZE - 1) , %sp                       ;/*  ջָ�����                  */

2:
    ;/*
    ; * �л����жϰ�ȫջ
    ; */
    SET     _G_ulIntSafeStack , %l0                                     ;/*  %l0 = _G_ulIntSafeStack     */

#if LW_CFG_SMP_EN > 0
    READ_CPUID(%l1)                                                     ;/*  %l1 = CPU_ID                */
    SLL     %l1   , 2   , %l1                                           ;/*  %l1 = CPU_ID * 4            */
    ADD     %l1   , %l0 , %l0                                           ;/*  %l0 = &safestack[CPU_ID]    */
#endif

    LD      [%l0] , %l1                                                 ;/*  %l1 = �жϰ�ȫջ            */
    SUB     %l1   , ASM_STACK_FRAME_SIZE , %sp                          ;/*  ����ջ�ռ�                  */

3:
    CALL    \handle
    MOV     %g7   , %o0

    CALL    API_InterExit
    NOP

    MOV     %g6   , %g1
    RESTORE_REGS
    MACRO_END()

;/*********************************************************************************************************
;  data_store_error ��ں�
;*********************************************************************************************************/

FUNC_DEF(archDataStoreErrEntry)
    SPARC_TRAP_ENTRY        archDataStoreErrHandle  PC_ARG_REG
    FUNC_END(archDataStoreErrEntry)

;/*********************************************************************************************************
;  instruction_access_MMU_miss ��ں�
;*********************************************************************************************************/

FUNC_DEF(archInstAccessMmuMissEntry)
    SPARC_TRAP_ENTRY        archInstAccessMmuMissHandle  PC_ARG_REG
    FUNC_END(archInstAccessMmuMissEntry)

;/*********************************************************************************************************
;  instruction_access_error ��ں�
;*********************************************************************************************************/

FUNC_DEF(archInstAccessErrEntry)
    SPARC_TRAP_ENTRY        archInstAccessErrHandle  PC_ARG_REG
    FUNC_END(archInstAccessErrEntry)

;/*********************************************************************************************************
;  r_register_access_error ��ں�
;*********************************************************************************************************/

FUNC_DEF(archRRegAccessErrEntry)
    SPARC_TRAP_ENTRY        archRRegAccessErrHandle  PC_ARG_REG
    FUNC_END(archRRegAccessErrEntry)

;/*********************************************************************************************************
;  instruction_access_exception ��ں�
;*********************************************************************************************************/

FUNC_DEF(archInstAccessExcEntry)
    SPARC_TRAP_ENTRY        archInstAccessExcHandle  PC_ARG_REG
    FUNC_END(archInstAccessExcEntry)

;/*********************************************************************************************************
;  privileged_instruction ��ں�
;*********************************************************************************************************/

FUNC_DEF(archPrivInstEntry)
    SPARC_TRAP_ENTRY        archPrivInstHandle  PC_ARG_REG
    FUNC_END(archPrivInstEntry)

;/*********************************************************************************************************
;  illegal_instruction ��ں�
;*********************************************************************************************************/

FUNC_DEF(archIllegalInstEntry)
    SPARC_TRAP_ENTRY        archIllegalInstHandle  PC_ARG_REG
    FUNC_END(archIllegalInstEntry)

;/*********************************************************************************************************
;  fp_disabled ��ں�
;*********************************************************************************************************/

FUNC_DEF(archFpDisableEntry)
    SPARC_TRAP_ENTRY        archFpDisableHandle  PC_ARG_REG
    FUNC_END(archFpDisableEntry)

;/*********************************************************************************************************
;  cp_disabled ��ں�
;*********************************************************************************************************/

FUNC_DEF(archCpDisableEntry)
    SPARC_TRAP_ENTRY        archCpDisableHandle  PC_ARG_REG
    FUNC_END(archCpDisableEntry)

;/*********************************************************************************************************
;  unimplemented_FLUSH ��ں�
;*********************************************************************************************************/

FUNC_DEF(archUnimplFlushEntry)
    SPARC_TRAP_ENTRY        archUnimplFlushHandle  PC_ARG_REG
    FUNC_END(archUnimplFlushEntry)

;/*********************************************************************************************************
;  watchpoint_detected ��ں�
;*********************************************************************************************************/

FUNC_DEF(archWatchPointDectectEntry)
    SPARC_TRAP_ENTRY        archWatchPointDectectHandle  PC_ARG_REG
    FUNC_END(archWatchPointDectectEntry)

;/*********************************************************************************************************
;  mem_address_not_aligned ��ں�
;*********************************************************************************************************/

FUNC_DEF(archMemAddrNoAlignEntry)
    SPARC_TRAP_ENTRY        archMemAddrNoAlignHandle  PC_ARG_REG
    FUNC_END(archMemAddrNoAlignEntry)

;/*********************************************************************************************************
;  fp_exception ��ں�
;*********************************************************************************************************/

FUNC_DEF(archFpExcEntry)
    SPARC_TRAP_ENTRY        archFpExcHandle  PC_ARG_REG
    FUNC_END(archFpExcEntry)

;/*********************************************************************************************************
;  cp_exception ��ں�
;*********************************************************************************************************/

FUNC_DEF(archCpExcEntry)
    SPARC_TRAP_ENTRY        archCpExcHandle  PC_ARG_REG
    FUNC_END(archCpExcEntry)

;/*********************************************************************************************************
;  data_access_error ��ں�
;*********************************************************************************************************/

FUNC_DEF(archDataAccessErrEntry)
    SPARC_TRAP_ENTRY        archDataAccessErrHandle  PC_ARG_REG
    FUNC_END(archDataAccessErrEntry)

;/*********************************************************************************************************
;  data_access_MMU_miss ��ں�
;*********************************************************************************************************/

FUNC_DEF(archDataAccessMmuMissEntry)
    SPARC_TRAP_ENTRY        archDataAccessMmuMissHandle  PC_ARG_REG
    FUNC_END(archDataAccessMmuMissEntry)

;/*********************************************************************************************************
;  data_access_exception ��ں�
;*********************************************************************************************************/

FUNC_DEF(archDataAccessExcEntry)
    SPARC_TRAP_ENTRY        archDataAccessExcHandle  PC_ARG_REG
    FUNC_END(archDataAccessExcEntry)

;/*********************************************************************************************************
;  tag_overflow ��ں�
;*********************************************************************************************************/

FUNC_DEF(archTagOverFlowEntry)
    SPARC_TRAP_ENTRY        archTagOverFlowHandle  PC_ARG_REG
    FUNC_END(archTagOverFlowEntry)

;/*********************************************************************************************************
;  division_by_zero ��ں�
;*********************************************************************************************************/

FUNC_DEF(archDivZeroEntry)
    SPARC_TRAP_ENTRY        archDivZeroHandle  PC_ARG_REG
    FUNC_END(archDivZeroEntry)

;/*********************************************************************************************************
;  trap_instruction ��ں�
;*********************************************************************************************************/

FUNC_DEF(archTrapInstEntry)
    SPARC_TRAP_ENTRY        archTrapInstHandle  PC_ARG_REG
    FUNC_END(archIntEntry)

;/*********************************************************************************************************
;  interrupt_level_n ��ں�
;*********************************************************************************************************/

FUNC_DEF(archIntEntry)
    SPARC_TRAP_ENTRY        bspIntHandle  TRAP_TYPE_ARG_REG
    FUNC_END(archIntEntry)

    FILE_END()
;/*********************************************************************************************************
;  END
;*********************************************************************************************************/