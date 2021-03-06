USE [GZFrameworkDemo_Business]
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetChildCategory]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_GetChildCategory](
	@CategoryID VARCHAR(10)
)
RETURNS @RESULT TABLE(
	CategoryID VARCHAR(10)
)
AS
BEGIN
	/***************************************************
		-- 功能：获得子类别
		-- 作者：GarsonZhang
		-- 时间：2017-05-03 13:51:57
		-- 备注：
		-- 测试：
	***************************************************/
	INSERT INTO @RESULT( CategoryID )
	SELECT CategoryID 
	FROM dbo.tb_ProductCategory 
	WHERE CategoryID=@CategoryID
		
	WHILE EXISTS(SELECT * FROM dbo.tb_ProductCategory WHERE ParentCategoryID IN(SELECT CategoryID FROM @RESULT) AND CategoryID NOT IN (SELECT CategoryID FROM @RESULT))
	BEGIN
		INSERT INTO @RESULT( CategoryID )
		SELECT CategoryID FROM dbo.tb_ProductCategory WHERE ParentCategoryID IN(SELECT CategoryID FROM @RESULT) AND CategoryID NOT IN (SELECT CategoryID FROM @RESULT)
	END
	RETURN;
END
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetDiffYear]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ufn_GetDiffYear](
	@Date1 DATETIME,
	@Date2 DATETIME
)
RETURNS INT
AS
BEGIN
	--PRINT dbo.ufn_GetDiffYear('1990-02-17','2015-03-01')
	DECLARE @Years INT
	SET @Years=DATEDIFF(YEAR,@Date1,@Date2)

	IF(DATEADD(YEAR,@Years,@Date1)<@Date2)
		SET @Years=@Years+1
	
	IF(DATEADD(YEAR,@Years,@Date1)>@Date2)
		SET @Years=@Years-1

	RETURN @Years
END

GO
/****** Object:  UserDefinedFunction [dbo].[ufn_GetSpellCode]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 功能：汉字转换成拼音首字母 首字母查
-- =============================================
CREATE FUNCTION [dbo].[ufn_GetSpellCode](@Str   varchar(500)='')  
  returns   varchar(500)  
  as 
 
  begin  
      --定义变量
      declare   @strlen   int, @return   varchar(500), @ii   int  
      declare   @n   int, @c   char(1),@chn   nchar(1)  
       --设置初始值
      select   @strlen=len(@str),@return='',@ii=0  
      set   @ii=0  
      --开始循环取出没个字符
      while   @ii<@strlen  
      begin  
          select   @ii=@ii+1,@n=63,@chn=substring(@str,@ii,1)  
          if   @chn>'z'  
          select   @n   =   @n   +1  ,@c   =   case   chn   when   @chn   then   char(@n)   else   @c   end  
          from(  
              select   top   27   *  
              from(  
                  select   chn   =   '吖'  
                  union   all   select   '八'  
                  union   all   select   '嚓'  
                  union   all   select   '咑'  
                  union   all   select   '妸'  
                  union   all   select   '发'  
                  union   all   select   '旮'  
                  union   all   select   '铪'  
                  union   all   select   '丌' --because   have   no   'i'  
                  union   all   select   '丌'  
                  union   all   select   '咔'  
                  union   all   select   '垃'  
                  union   all   select   '嘸'  
                  union   all   select   '拏'  
                  union   all   select   '噢'  
                  union   all   select   '妑'  
                  union   all   select   '七'  
                  union   all   select   '呥'  
                  union   all   select   '仨'  
                  union   all   select   '他'  
                  union   all   select   '屲' --no   'u'  
                  union   all   select   '屲' --no   'v'  
                  union   all   select   '屲'  
                  union   all   select   '夕'  
                  union   all   select   '丫'  
                  union   all   select   '帀'  
                  union   all   select   @chn
              )   as   a  
              order   by   chn   COLLATE   Chinese_PRC_CI_AS    
          )   as   b  
          else   set   @c=@chn  
          set   @return=@return+@c  
      end  
      return(@return)  
  end
GO
/****** Object:  UserDefinedFunction [dbo].[ufn_SplitEx]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ufn_SplitEx]
(
	@C VARCHAR(8000), --字符串
	@SPLIT VARCHAR(2), --分隔符
	@DeleEmpty INT--1,删除空值，2，不删除空
)
RETURNS @T TABLE(COL VARCHAR(50))   
AS   
BEGIN   

/***************************************************************
功能：SQL分割字符串并返回表

--测试案例：
SELECT * FROM dbo.ufn_SplitEx('11 ,22,33,44,55 ',',',1)
SELECT * FROM dbo.ufn_SplitEx(',22,',',',1)
SELECT * FROM dbo.ufn_SplitEx('10a0c745bd9f454baed387c02975dbce,382f031293214b15bd7f900ac0652a2b,8d0b1424ea6a4029bc13429fa9eb3398,9dfa32b6c61543c2b027b96c0693c1a2,c60520184e8d47f6b6dd3d9033d76877,c7f091144a2149c2a509343d1bac62d9,',',',1)
***************************************************************/
	IF ISNULL(@C,'')='' RETURN
	
	
	DECLARE @tmp VARCHAR(2000)
	
	WHILE(CHARINDEX(@SPLIT,@C)<>0)   
	BEGIN   
		SET @tmp=''
		SET @tmp=RTRIM(LTRIM(SUBSTRING(@C,1,CHARINDEX(@SPLIT,@C)-1)))
		
		--IF((SELECT COUNT(*) FROM @T WHERE COL=@tmp)=0)
			INSERT @T(COL) VALUES (@tmp)   
		SET @C=STUFF(@C,1,CHARINDEX(@SPLIT,@C),'')
	END 
	--IF((SELECT COUNT(*) FROM [@T] WHERE COL=@tmp)=0)  
		INSERT @T(COL) VALUES (RTRIM(LTRIM(@C)))  
	
	IF(@DeleEmpty=1)
		DELETE @T WHERE ISNULL(COL,'')=''
	
	RETURN   
END
GO
/****** Object:  Table [dbo].[dt_CommonDicData]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dt_CommonDicData](
	[isid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[rowversion] [timestamp] NULL,
	[DataType] [nvarchar](20) NULL,
	[DataCode] [varchar](20) NULL,
	[DataName] [nvarchar](20) NULL,
	[SortIndex] [int] NULL,
	[CreateUser] [varchar](20) NULL,
	[CreateDate] [datetime] NULL,
	[LastUpdateUser] [varchar](20) NULL,
	[LastUpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DT_COMMONDICDATA] PRIMARY KEY CLUSTERED 
(
	[isid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[dt_Data_CompanyInfo]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dt_Data_CompanyInfo](
	[isid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CompanyName] [nvarchar](50) NULL,
	[CompanyAddress] [nvarchar](100) NULL,
	[Phone] [nvarchar](50) NULL,
	[Mobile] [nvarchar](50) NULL,
	[Fax] [nvarchar](50) NULL,
	[PublicAccount] [nvarchar](50) NULL,
	[PublicName] [nvarchar](50) NULL,
	[PublicBackInfo] [nvarchar](50) NULL,
	[PrivateAccount] [nvarchar](50) NULL,
	[PrivateBankName] [nvarchar](50) NULL,
	[PrivateName] [nvarchar](50) NULL,
	[LastUpdateUser] [varchar](20) NULL,
	[LastUpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DT_DATA_COMPANYINFO] PRIMARY KEY CLUSTERED 
(
	[isid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[dt_MySupplier]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dt_MySupplier](
	[SupplierID] [varchar](10) NOT NULL,
	[SupplierName] [varchar](20) NULL,
	[Address] [nvarchar](200) NULL,
	[Contacts] [nvarchar](20) NULL,
	[Phone] [varchar](20) NULL,
	[Remark] [nvarchar](200) NULL,
	[CreateUser] [varchar](20) NULL,
	[CreateDate] [datetime] NULL,
	[LastUpdateUser] [varchar](20) NULL,
	[LastUpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DT_MYROLE] PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sys_DataSN]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sys_DataSN](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[DocCode] [varchar](50) NOT NULL,
	[DocName] [nvarchar](50) NULL,
	[DocHeader] [varchar](10) NULL,
	[Separate] [varchar](2) NULL,
	[DocType] [varchar](20) NULL,
	[Length] [int] NOT NULL,
	[Demo] [nvarchar](50) NULL,
 CONSTRAINT [PK_SYS_DATASN] PRIMARY KEY CLUSTERED 
(
	[DocCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sys_DataSNDetail]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sys_DataSNDetail](
	[DocCode] [varchar](50) NOT NULL,
	[Seed] [varchar](50) NOT NULL,
	[MaxID] [int] NULL,
 CONSTRAINT [PK_SYS_DATASNDETAIL] PRIMARY KEY CLUSTERED 
(
	[DocCode] ASC,
	[Seed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_Activity]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Activity](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [varchar](10) NULL,
	[ActivityName] [nvarchar](50) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_BarCodeSetting]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_BarCodeSetting](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[Head1] [nvarchar](20) NULL,
	[Head2] [nvarchar](20) NULL,
	[Head3] [nvarchar](20) NULL,
	[Item1] [nvarchar](20) NULL,
	[Item2] [nvarchar](20) NULL,
	[Item3] [nvarchar](20) NULL,
 CONSTRAINT [PK_tb_BarCodeSetting] PRIMARY KEY CLUSTERED 
(
	[isid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_PO]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_PO](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[DocNo] [varchar](50) NOT NULL,
	[DocDate] [datetime] NULL,
	[TotalQty] [int] NULL,
	[TotalPOAmount] [decimal](18, 2) NULL,
	[AppStatus] [int] NULL,
	[AppUser] [varchar](20) NULL,
	[AppDate] [datetime] NULL,
	[CreateUser] [varchar](20) NULL,
	[CreateDate] [datetime] NULL,
 CONSTRAINT [PK_TB_PO] PRIMARY KEY CLUSTERED 
(
	[DocNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_PODetail]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_PODetail](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[DocNo] [varchar](50) NULL,
	[BarCode] [varchar](50) NULL,
	[ItemNo] [varchar](50) NULL,
	[ItemName] [nvarchar](100) NULL,
	[CategoryID] [varchar](10) NULL,
	[POPrice] [decimal](18, 2) NULL,
	[SOPrice] [decimal](18, 2) NULL,
	[Color] [varchar](20) NULL,
	[Size] [varchar](10) NULL,
	[Qty] [int] NULL,
	[TotalPOAmount] [decimal](18, 2) NULL,
	[CreateUser] [varchar](20) NULL,
	[CreateDate] [datetime] NULL,
	[LastUpdateUser] [varchar](20) NULL,
	[LastUPdateDate] [datetime] NULL,
 CONSTRAINT [PK_TB_PODETAIL] PRIMARY KEY CLUSTERED 
(
	[isid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_ProductCategory]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ProductCategory](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[Flag] [varchar](100) NULL,
	[CategoryID] [varchar](10) NOT NULL,
	[CategoryName] [nvarchar](100) NULL,
	[ParentCategoryID] [varchar](10) NULL,
 CONSTRAINT [PK_TB_PRODUCTCATEGORY] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_ProductInventory]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ProductInventory](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[BarCode] [varchar](50) NOT NULL,
	[ItemNo] [varchar](50) NULL,
	[ItemName] [nvarchar](100) NULL,
	[CategoryID] [varchar](10) NULL,
	[SOPrice] [decimal](18, 2) NULL,
	[Color] [varchar](20) NULL,
	[Size] [varchar](10) NULL,
	[Qty] [int] NULL,
 CONSTRAINT [PK_TB_PRODUCTINVENTORY] PRIMARY KEY CLUSTERED 
(
	[BarCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_SaleInventory]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_SaleInventory](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[DocNo] [varchar](10) NOT NULL,
	[DocDate] [datetime] NULL,
	[StarDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[AmountInit] [decimal](18, 2) NULL,
	[AmountSale] [decimal](18, 2) NULL,
	[AmountPlan] [decimal](18, 2) NULL,
	[AmountRel] [decimal](18, 2) NULL,
	[AmountCompared] [decimal](18, 2) NULL,
	[AmountTakeOut] [decimal](18, 2) NULL,
	[AmountRemaining] [decimal](18, 2) NULL,
	[Remark] [nvarchar](100) NULL,
	[AppUser] [varchar](20) NULL,
	[AppDate] [datetime] NULL,
	[CreateUser] [varchar](20) NULL,
	[CreateDate] [datetime] NULL,
	[LastUpdteUser] [varchar](20) NULL,
	[LastUpdateDate] [datetime] NULL,
 CONSTRAINT [PK_TB_SALEINVENTORY] PRIMARY KEY CLUSTERED 
(
	[DocNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_Sales]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Sales](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[SaleID] [varchar](20) NOT NULL,
	[SaleName] [nvarchar](10) NULL,
 CONSTRAINT [PK_TB_SALES] PRIMARY KEY CLUSTERED 
(
	[SaleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_SO]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_SO](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[DocNo] [varchar](20) NOT NULL,
	[DocDate] [datetime] NULL,
	[TotalQty] [int] NULL,
	[TotalPrice] [decimal](18, 2) NULL,
	[ActivityID] [varchar](10) NULL,
	[ActivityName] [nvarchar](50) NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[AmountIn] [decimal](18, 2) NULL,
	[AmountOut] [decimal](18, 2) NULL,
	[SaleBy] [varchar](20) NULL,
	[CreateUser] [varchar](20) NULL,
	[CreateDate] [datetime] NULL,
 CONSTRAINT [PK_TB_SO] PRIMARY KEY CLUSTERED 
(
	[DocNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tb_SODetail]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_SODetail](
	[isid] [int] IDENTITY(1,1) NOT NULL,
	[DocNo] [varchar](20) NULL,
	[BarCode] [varchar](50) NULL,
	[ItemNo] [varchar](50) NULL,
	[ItemName] [nvarchar](100) NULL,
	[CategoryID] [varchar](10) NULL,
	[Color] [varchar](10) NULL,
	[Size] [varchar](10) NULL,
	[Qty] [int] NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[ActivityID] [varchar](10) NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[SaleBy] [varchar](20) NULL,
	[Remark] [nvarchar](100) NULL,
	[CreateUser] [varchar](20) NULL,
	[CreateDate] [datetime] NULL,
 CONSTRAINT [PK_TB_SODETAIL] PRIMARY KEY CLUSTERED 
(
	[isid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_PODetail]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_PODetail]
AS
	SELECT DocNo,BarCode,ItemNo,ItemName,Color,Size,SUM(Qty) AS Qty FROM dbo.tb_PODetail GROUP BY DocNo,BarCode,ItemNo,ItemName,Color,Size
GO
/****** Object:  View [dbo].[vw_Size]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Size]
AS
	SELECT * FROM dt_CommonDicData WHERE DataType='尺码'
GO
/****** Object:  StoredProcedure [dbo].[sys_GetDataSN]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sys_GetDataSN] 
    @DocCode VARCHAR(50),
    @CustomerSeed VARCHAR(50)='',
    @CustomerHead VARCHAR(50)=''
AS
BEGIN
/*-------------------------------------------------------------------------------------
  程序说明:返回单据号码
  返回结果:MAX_NO
  -------------------------------------------------------------------------------------

sys_GetDataSN 'PONO'

SELECT * FROM dbo.sys_DataSN

-------------------------------------------------------------------------------------*/

	IF NOT EXISTS(SELECT * FROM sys_DataSN WHERE DocCode=@DocCode)
	BEGIN
		SELECT ''
		RETURN;
	END
	
	DECLARE @DocHeader VARCHAR(50),@DocType VARCHAR(50),@Length INT,@Separate VARCHAR(2)

	SELECT @DocHeader=DocHeader,@DocType=DocType,@Length=[Length] FROM sys_DataSN WHERE DocCode=@DocCode
	
	
	DECLARE @DocSeed VARCHAR(100)
	IF(@DocType='Year')--年,递增
	BEGIN
		SET @DocSeed=CONVERT(VARCHAR(4),GETDATE(),23)
		SET @DocHeader=ISNULL(@DocHeader,'')+CONVERT(VARCHAR(4),GETDATE(),112)
	END
	
	IF(@DocType='Year-Month')--年-月,递增
	BEGIN
		SET @DocSeed=CONVERT(VARCHAR(7),GETDATE(),23)
		SET @DocHeader=ISNULL(@DocHeader,'')+CONVERT(VARCHAR(6),GETDATE(),112)
	END
		
	IF(@DocType='Year-Month-dd')--年-月-日,递增
	BEGIN
		SET @DocSeed=CONVERT(VARCHAR(10),GETDATE(),23)
		SET @DocHeader=ISNULL(@DocHeader,'')+CONVERT(VARCHAR,GETDATE(),112)
	END
		
	IF(@DocType='Up')--直接递增
		SET @DocSeed=@DocCode
	IF(@DocType='Customer')--自定义
		SET @DocSeed=@CustomerSeed
	
	DECLARE @Value VARCHAR(100)
	EXEC sys_GetDataSNBase @DocCode,@DocSeed,@Length,@Value OUTPUT
	
	--SELECT @DocType,@DocSeed,@DocHeader,@Value
	IF(@DocType='Customer')
		SELECT ISNULL(@CustomerHead,'')+@Value
	ELSE
		SELECT ISNULL(@DocHeader,'')+ISNULL(@Separate,'')+@Value
  -----------------------------------------END--------------------------------------------
END

GO
/****** Object:  StoredProcedure [dbo].[sys_GetDataSNBase]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[sys_GetDataSN]    Script Date: 01/22/2016 09:23:29 ******/
CREATE procedure [dbo].[sys_GetDataSNBase] 
    @DocCode VARCHAR(50),
    @Seed VARCHAR(50),
    @Length INT =4, --预设4位长度 
    @Result VARCHAR(50) OUT
AS
BEGIN
/*-------------------------------------------------------------------------------------
  程序说明:返回单据号码
  返回结果:MAX_NO
  -------------------------------------------------------------------------------------
--delete FROM sys_DataSN
select FROM sys_DataSN

---测试--------


sys_GetDataSNBase 'A',4 

select * from sys_DataSN
select * from sys_DataSNDetail

DECLARE @param1 VARCHAR(100)
EXEC sys_GetDataSNBase '9','',4,@param1 OUTPUT
SELECT @param1

-------------------------------------------------------------------------------------*/
	DECLARE @Value INT

	SELECT @Value=MaxID FROM dbo.sys_DataSNDetail WHERE DocCode=@DocCode AND Seed=@Seed

	IF (@Value IS NULL)
	BEGIN
	    SELECT @Value=0
		INSERT INTO dbo.sys_DataSNDetail(DocCode,Seed,MaxID)
		VALUES (@DocCode,@Seed,0)
	END

	SET @Value=ISNULL(@Value,0)+1 /*取最大值+1,为返回的流水号,过滤掉带4的号码*/

	WHILE(CHARINDEX('4',@Value)>0)
	BEGIN
		SET @Value=@Value+1
	END
	WHILE(CHARINDEX('47',@Value)>0)/*过滤掉带47的号码*/
	BEGIN
		SET @Value=@Value+1
	END
	
	UPDATE dbo.sys_DataSNDetail SET MaxID=@Value WHERE DocCode=@DocCode AND Seed=@Seed /*更新流水号*/

	SET @Result=RIGHT(REPLACE(SPACE(@Length),' ','0')+CAST(@Value AS VARCHAR),@Length)	


	RETURN
  -----------------------------------------END--------------------------------------------
END

GO
/****** Object:  StoredProcedure [dbo].[usp_BarCodeSetting_GetContent]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_BarCodeSetting_GetContent]
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM dbo.tb_BarCodeSetting)
		INSERT INTO dbo.tb_BarCodeSetting
		        ( Head1 ,
		          Head2 ,
		          Head3 ,
		          Item1 ,
		          Item2 ,
		          Item3
		        )
		VALUES  ( N'' , -- Head1 - nvarchar(20)
		          N'' , -- Head2 - nvarchar(20)
		          N'' , -- Head3 - nvarchar(20)
		          N'[款号]' , -- Item1 - nvarchar(20)
		          N'[颜色]' , -- Item2 - nvarchar(20)
		          N'[尺码]'  -- Item3 - nvarchar(20)
		        )
	SELECT ISNULL(Head1,'')+ISNULL(Item1,'')+ISNULL(Head2,'')+ISNULL(Item2,'')+ISNULL(Head3,'')+ISNULL(Item3,'') FROM dbo.tb_BarCodeSetting 
END
GO
/****** Object:  StoredProcedure [dbo].[usp_PO_Approval]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_PO_Approval]
	@DocNo VARCHAR(50),
	@Account VARCHAR(20),
	@AppStatus INT
AS
BEGIN
	/***************************************************
		-- 功能：入库审核 
		-- 作者：GarsonZhang
		-- 时间：2017-05-03 20:30:33
		-- 备注：
		-- 测试：
	***************************************************/
	UPDATE dbo.tb_PO SET AppStatus=@AppStatus,AppUser=@Account,APPDate=GETDATE() WHERE DocNo=@DocNo
	--SELECT * FROM dbo.tb_PO
	IF(ISNULL(@AppStatus,0)<1) RETURN;
	
	SELECT * INTO #tmp FROM dbo.tb_PODetail WHERE DocNo=@DocNo 
		
	IF(ISNULL(@AppStatus,0)=2)--审核通过 增加库存
		UPDATE #tmp SET Qty=ISNULL(Qty,0)*-1
		
	SELECT bisid=b.isid ,a.* INTO #union
	FROM #tmp AS a INNER JOIN dbo.tb_ProductInventory AS b 
		ON b.ItemNo = a.ItemNo AND b.Color = a.Color AND b.Size = a.Size AND b.BarCode = a.BarCode
	WHERE DocNo=@DocNo 
		
	
	--存在，增加库存
	UPDATE dbo.tb_ProductInventory SET Qty=ISNULL(dbo.tb_ProductInventory.Qty,0)+ISNULL(b.Qty,0),CategoryID=b.CategoryID FROM #union AS b 
	WHERE b.bisid=dbo.tb_ProductInventory.isid
	
	--不存在，新增一条
	INSERT INTO dbo.tb_ProductInventory(BarCode,ItemNo,ItemName,CategoryID,SOPrice,Color,Size,Qty)
	SELECT BarCode,ItemNo,ItemName,CategoryID,SOPrice,Color,Size,Qty FROM #tmp WHERE isid NOT IN(SELECT isid FROM #union)
END	
GO
/****** Object:  StoredProcedure [dbo].[usp_ProductInventory_GetDetail]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_ProductInventory_GetDetail]
	@ItemNo VARCHAR(50)=''
AS
BEGIN
	/***************************************************
		-- 功能：库存查询
		-- 作者：GarsonZhang
		-- 时间：2017-05-03 13:55:25
		-- 备注：
		-- 测试：
		usp_ProductInventory_GetDetail '201405'
		select * from tb_ProductInventory
	***************************************************/

	SELECT ItemName FROM dbo.tb_ProductInventory WHERE ItemNo=@ItemNo
END	
GO
/****** Object:  StoredProcedure [dbo].[usp_ProductInventory_Search]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ProductInventory_Search]
	@ProductCategory VARCHAR(20)=''
AS
BEGIN
	/***************************************************
		-- 功能：库存查询
		-- 作者：GarsonZhang
		-- 时间：2017-05-03 13:55:25
		-- 备注：
		-- 测试：
		usp_ProductInventory_Search 'C001-'
	***************************************************/
	IF(ISNULL(@ProductCategory,'')='')
		SELECT a.*,b.CategoryName,Tag=a.ItemNo+'    '+a.ItemName FROM dbo.tb_ProductInventory AS a LEFT JOIN dbo.tb_ProductCategory AS b ON b.CategoryID = a.CategoryID
	ELSE
	BEGIN
		SELECT a.*,b.CategoryName,Tag=a.ItemNo+'    '+a.ItemName FROM dbo.tb_ProductInventory AS a LEFT JOIN dbo.tb_ProductCategory AS b ON b.CategoryID = a.CategoryID
		WHERE  a.CategoryID IN (SELECT CategoryID from dbo.ufn_GetChildCategory(@ProductCategory))
	END
END	
GO
/****** Object:  StoredProcedure [dbo].[usp_ProductInventory_SearchBarCode]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_ProductInventory_SearchBarCode]
	@Code VARCHAR(50)
AS
BEGIN
	/***************************************************
		-- 功能：库存查询
		-- 作者：GarsonZhang
		-- 时间：2017-05-03 13:55:25
		-- 备注：
		-- 测试：
		usp_ProductInventory_Search 'C001-'
	***************************************************/

	SELECT a.*,b.CategoryName,Tag=a.ItemNo+'    '+a.ItemName 
	FROM dbo.tb_ProductInventory AS a LEFT JOIN dbo.tb_ProductCategory AS b ON b.CategoryID = a.CategoryID
	WHERE a.ItemNo LIKE '%'+@Code+'%' OR a.BarCode LIKE '%'+@Code+'%'
	
END	
GO
/****** Object:  StoredProcedure [dbo].[usp_ProductInventory_SearchList]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_ProductInventory_SearchList]
	@ProductCategory VARCHAR(20)=''
AS
BEGIN
	/***************************************************
		-- 功能：库存查询
		-- 作者：GarsonZhang
		-- 时间：2017-05-03 13:55:25
		-- 备注：
		-- 测试：
		usp_ProductInventory_SearchList ''
	***************************************************/
	IF(ISNULL(@ProductCategory,'')='')
		SELECT ItemNo,ItemName,CategoryID,SOPrice,Qty=SUM(ISNULL(Qty,0))
		FROM dbo.tb_ProductInventory 
		GROUP BY ItemNo,ItemName,CategoryID,SOPrice
	ELSE
	BEGIN
		SELECT ItemNo,ItemName,CategoryID,SOPrice,Qty=SUM(ISNULL(Qty,0))
		FROM dbo.tb_ProductInventory 
		WHERE  CategoryID IN (SELECT CategoryID from dbo.ufn_GetChildCategory(@ProductCategory))
		GROUP BY ItemNo,ItemName,CategoryID,SOPrice
	END
END	
GO
/****** Object:  StoredProcedure [dbo].[usp_SO_Approval]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_SO_Approval]
	@DocNo VARCHAR(20)
AS
BEGIN

	SELECT BarCode,Size,Color,Qty=SUM(ISNULL(Qty,0)) INTO #tmp FROM dbo.tb_SODetail 
	WHERE DocNo=@DocNo
	GROUP BY BarCode,Size,Color
	
	UPDATE dbo.tb_ProductInventory SET Qty=ISNULL(dbo.tb_ProductInventory.Qty,0)-ISNULL(a.Qty,0) FROM #tmp AS a 
	WHERE a.BarCode=dbo.tb_ProductInventory.BarCode AND dbo.tb_ProductInventory.Size=a.Size AND dbo.tb_ProductInventory.Color=a.Color
	
END	

GO
/****** Object:  StoredProcedure [dbo].[usp_SO_SearchList]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_SO_SearchList]
	@Date1 DATETIME,
	@Date2 DATETIME
AS
BEGIN
	/***************************************************
		-- 功能：销售统计
		-- 作者：GarsonZhang
		-- 时间：2017-05-05 12:59:59
		-- 备注：
		-- 测试：
		usp_SO_SearchList '2017-05-05','2017-05-05'
	***************************************************/
	--PRINT CONVERT(VARCHAR(2),GETDATE(),8)
	
	DECLARE @Time2 DATETIME
	SET @Time2=DATEADD(SECOND,-1,DATEADD(DAY,1,@Date2))
	SELECT *,CONVERT(VARCHAR(2),CreateDate,8)+':00' AS [Hour] FROM dbo.tb_SODetail WHERE CreateDate BETWEEN @Date1 AND @Time2 ORDER BY CreateDate DESC
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SO_SearchTopList]    Script Date: 2017-06-21 23:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_SO_SearchTopList]
	@TopNum INT
AS
BEGIN
	/***************************************************
		-- 功能：销售统计
		-- 作者：GarsonZhang
		-- 时间：2017-05-05 12:59:59
		-- 备注：
		-- 测试：
		usp_SO_SearchTopList 20
	***************************************************/
	
	DECLARE @SQL VARCHAR(500)
	SET @SQL='SELECT TOP '+CAST(@TopNum AS VARCHAR)+' * FROM dbo.tb_SODetail ORDER BY CreateDate DESC'
	EXEC( @SQL)
	
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增字段' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'rowversion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'rowversion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'字典类型' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'DataType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'数据编码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'DataCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'数据名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'DataName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'显示索引' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'SortIndex'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'LastUpdateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'修改日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData', @level2type=N'COLUMN',@level2name=N'LastUpdateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'公共基础字典' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_CommonDicData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'公司名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'CompanyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'CompanyAddress'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'电话' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'Phone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'手机' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'Mobile'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'传真' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'Fax'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'对公账号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'PublicAccount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'对公账号公司名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'PublicName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'对公账号开户行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'PublicBackInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'私人账号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'PrivateAccount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'私人账号开户行' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'PrivateBankName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'私人账号姓名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'PrivateName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最后修改人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'LastUpdateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最后修改时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo', @level2type=N'COLUMN',@level2name=N'LastUpdateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'公司信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_Data_CompanyInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'供应商编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'SupplierID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'供应商名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'SupplierName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'Address'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'联系人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'Contacts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'联系电话' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'Phone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CreateUser' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CreateDate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LastUpdateUser' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'LastUpdateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'LastUpdateDate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier', @level2type=N'COLUMN',@level2name=N'LastUpdateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'供应商' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'dt_MySupplier'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增字段' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_DataSN', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'单据标识' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_DataSN', @level2type=N'COLUMN',@level2name=N'DocCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'长度' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_DataSN', @level2type=N'COLUMN',@level2name=N'Length'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'单据号码表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_DataSN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'单据标识' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_DataSNDetail', @level2type=N'COLUMN',@level2name=N'DocCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最大号码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_DataSNDetail', @level2type=N'COLUMN',@level2name=N'MaxID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'单据号码表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_DataSNDetail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Activity', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Activity', @level2type=N'COLUMN',@level2name=N'ActivityID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动内容' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Activity', @level2type=N'COLUMN',@level2name=N'ActivityName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动开始日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Activity', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动结束日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Activity', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动列表' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Activity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_BarCodeSetting', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自定义1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_BarCodeSetting', @level2type=N'COLUMN',@level2name=N'Head1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自定义2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_BarCodeSetting', @level2type=N'COLUMN',@level2name=N'Head2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自定义3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_BarCodeSetting', @level2type=N'COLUMN',@level2name=N'Head3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'项目1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_BarCodeSetting', @level2type=N'COLUMN',@level2name=N'Item1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'项目2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_BarCodeSetting', @level2type=N'COLUMN',@level2name=N'Item2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'项目3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_BarCodeSetting', @level2type=N'COLUMN',@level2name=N'Item3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商品编码生成' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_BarCodeSetting'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'入库编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'DocNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'入库日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'DocDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'总件数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'TotalQty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'进货总金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'TotalPOAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'审核人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'AppUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'审核时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'AppDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'入库单' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'入库编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'DocNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商品编码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'BarCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'货号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'ItemNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'货物名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'ItemName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'入库类别' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'CategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'进价' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'POPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售价' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'SOPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'颜色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'Color'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'尺码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'件数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'Qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'进货金额小计' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'TotalPOAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'入库单明细' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_PODetail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductCategory', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tag' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductCategory', @level2type=N'COLUMN',@level2name=N'Flag'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'类别编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductCategory', @level2type=N'COLUMN',@level2name=N'CategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'类别名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductCategory', @level2type=N'COLUMN',@level2name=N'CategoryName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'父级类别' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductCategory', @level2type=N'COLUMN',@level2name=N'ParentCategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商品类别' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductCategory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商品编码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'BarCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'货号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'ItemNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'货物名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'ItemName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'入库类别' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'CategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售价' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'SOPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'颜色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'Color'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'尺码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'件数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory', @level2type=N'COLUMN',@level2name=N'Qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'库存信息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_ProductInventory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'结算编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'DocNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'结算时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'DocDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'起始时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'StarDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'截至时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'钱箱金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AmountInit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AmountSale'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'应共计金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AmountPlan'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'实共计金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AmountRel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'盈亏金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AmountCompared'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'取出金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AmountTakeOut'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'剩余金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AmountRemaining'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'审核人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AppUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'审核时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'AppDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'LastUpdteUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory', @level2type=N'COLUMN',@level2name=N'LastUpdateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售结算' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SaleInventory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Sales', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售员编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Sales', @level2type=N'COLUMN',@level2name=N'SaleID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售员名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Sales', @level2type=N'COLUMN',@level2name=N'SaleName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售员' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_Sales'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'单据号码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'DocNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'DocDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'总数量' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'TotalQty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'总金额' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'TotalPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'ActivityID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'ActivityName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'最终收款' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'TotalAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'收钱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'AmountIn'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'找零' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'AmountOut'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售员' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'SaleBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售单' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'自增列' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'isid'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售单号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'DocNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'条码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'BarCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'货号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'ItemNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'商品名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'ItemName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'类别' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'CategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'颜色' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'Color'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'尺码' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'Size'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'件数' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'Qty'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'单价' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'UnitPrice'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'活动编号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'ActivityID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'总价' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'TotalAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售员' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'SaleBy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'备注' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'销售单明细' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tb_SODetail'
GO
