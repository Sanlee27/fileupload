<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.util.*"%>
<%
	String dir = request.getServletContext().getRealPath("/upload");

	System.out.println(dir);
	
	int max = 10 * 1024 * 1024;
	// request 객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑
	MultipartRequest mreq = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	
	// MultipartRequest API를 사용하여 스트림내에서 문자값을 반환 받을 수 있다.
	
	// 업로드 된 파일의 형식이 pdf가 아니면 return한다
	if(mreq.getContentType("boardFile").equals("application/pdf") == false){
		// 이미 저장된 파일을 삭제
		System.out.println("PDF파일이 아닙니다");
		String saveFilename = mreq.getFilesystemName("boardFile"); 
		File f = new File(dir+"/"+saveFilename); // 정확한 경로 필요 (d:/~/~/upload/~.gif)
		
		if(f.exists()){
			f.delete();
			System.out.println(saveFilename+"파일삭제");
		}
		response.sendRedirect(request.getContextPath()+"/addBoard.jsp");
		return;
	}
	
	// 1) input type="text" 값반환 API >> board 테이블에 저장
	String boardTitle = mreq.getParameter("boardTitle");
	String memberId = mreq.getParameter("memberId");
	
	System.out.println(boardTitle + " : addBoardAction boardTitle");
	System.out.println(memberId + " : addBoardAction memberId");
	
	Board board = new Board();
		board.setBoardTitle(boardTitle);
		board.setMemberId(memberId);
		
		
	// 2) input type="file" 값(파일메타정보) 반환 API (원본 파일이름, 저장된 파일이름, 컨텐츠타입) >> board_file 테이블에 저장
	// --- 파일(바이너리)은 이미 MultipartRequest 객체 생성시(request 랩핑시,line 9(Multi~)) 먼저 저장
	String type = mreq.getContentType("boardFile");
	String originFilename = mreq.getOriginalFileName("boardFile");
	String saveFilename = mreq.getFilesystemName("boardFile");
	
	System.out.println(type + " : addBoardAction type");
	System.out.println(originFilename + " : addBoardAction originFilename");
	System.out.println(saveFilename + " : addBoardAction saveFilename");
	
	BoardFile boardFile = new BoardFile();
		// boardFile.setBoardNo(boardNo);
		boardFile.setType(type);
		boardFile.setOriginFilename(originFilename);
		boardFile.setSaveFilename(saveFilename);
		
	/*		
	insert into board(boadr_title, member_id, updatedate, createdate) 
	values(?, ?, now(), now());
	
	insert into board_file(board_no, origin_filename, save_filename, path, type, createdate)
	values(?, ?, ?, ?, ?, now());
	*/
	
	//DB
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	String boardSql =  "insert into board(board_title, member_id, updatedate, createdate) values(?, ?, now(), now())";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS);
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberId);
	boardStmt.executeUpdate(); // board 입력 후 키값저장
	
	ResultSet keyRs = boardStmt.getGeneratedKeys(); // 저장된 키값 반환
	int boardNo = 0;
	if(keyRs.next()){
		boardNo = keyRs.getInt(1);
	}
	
	String fileSql = "insert into board_file(board_no, origin_filename, save_filename, type, path, createdate) values(?, ?, ?, ?, 'upload', now())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type);
	fileStmt.executeUpdate(); // board_file 입력
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	/* PreparedStatement boardStmt = conn.prepareStatement("insert into board(board_title, member_id, updatedate, createdate) values(?, ?, now(), now());");
	int boardRow = boardStmt.executeUpdate(); 
	PreparedStatement keyStmt = conn.prepareStatement("select MAX(board_no) from board"); */
	
%>
    