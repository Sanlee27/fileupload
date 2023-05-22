<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>    
<%@ page import = "java.io.*" %>
<%@ page import = "java.sql.*"%>
<%@ page import = "vo.*" %>
<%
	String dir = request.getServletContext().getRealPath("/upload");
	
	System.out.println(dir);

	int max = 10 * 1024 * 1024;
	
	// request 객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑 request >> mreq(멀티파트~)
	MultipartRequest mreq = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	// system.out.println(mreq.getOriginalFileName("boardFile") + " : boardFile");
	// mreq.getOriginalFileName("boardFile") 값이 null이면 board테이블에 title만 수정
	
	int boardNo = Integer.parseInt(mreq.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mreq.getParameter("boardFileNo"));
	
	System.out.println(boardNo + " : modifyBoardAction boardNo");
	System.out.println(boardFileNo + " : modifyBoardAction boardFileNo");
	
	// 1) board title 수정
	// System.out.println(mreq.getParameter("boardTitle") + " : modifyBoardAction request_boardTitle");

	String boardTitle = mreq.getParameter("boardTitle");
	
	System.out.println(boardTitle + " : modifyBoardAction boardTitle");
	
	//DB
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);

	// title 수정 쿼리
	String boardSql = "UPDATE board SET board_title = ? WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	
	System.out.println(boardStmt + " : modifyBoardAction boardStmt");
	
	boardStmt.setString(1, boardTitle);
	boardStmt.setInt(2, boardNo);
	int boardRow = boardStmt.executeUpdate();
	
	// 2) 이전 boardFile 삭제, 새로운 boardFile 추가 테이블을 수정
	if(mreq.getOriginalFileName("boardFile") != null){
		String originFileName = mreq.getOriginalFileName("boardFile");
		// 수정할 파일이 있으면
		// pdf 파일 유효성 검사
		if(mreq.getContentType("boardFile").equals("application/pdf") == false){
			String saveFilename = mreq.getFilesystemName("boardTitle");
			File f = new File(dir+"/"+saveFilename);
			if(f.exists()){
				f.delete();
				System.out.println(saveFilename + "삭제");
			} 
		} else { 
			// pdf파일이면
			// (1) 이전 파일(saveFilename) 삭제
			// (2) db수정(update)
			String type = mreq.getContentType("boardFile");
			String originFilename = mreq.getOriginalFileName("boardFile");
			String saveFilename = mreq.getFilesystemName("boardFile");
			
			System.out.println(type + " : modifyBoardAction type");
			System.out.println(originFilename + " : modifyBoardAction originFilename");
			System.out.println(saveFilename + " : modifyBoardAction saveFilename");
			
			BoardFile boardFile = new BoardFile();
				boardFile.setBoardFileNo(boardFileNo);
				boardFile.setType(type);
				boardFile.setOriginFilename(originFilename);
				boardFile.setSaveFilename(saveFilename);
				
			// (1) 이전 파일 삭제
			String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no = ?";
			PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
			saveFilenameStmt.setInt(1, boardFile.getBoardFileNo());
			ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
			String preSaveFilename = "";
			if(saveFilenameRs.next()){
				preSaveFilename = saveFilenameRs.getString("save_filename");
			}
			File f = new File(dir+"/"+preSaveFilename);
			if(f.exists()){
				f.delete();
			} 
			// (2) 수정된 파일의 정보로 db를 수정
			/*
				UPDATE board_file 
				SET origin_filename = ? AND save_filename = ? 
				WHERE board_file_no = ?
			*/
			String boardFileSql = "UPDATE board_file SET origin_filename = ? , save_filename = ? WHERE board_file_no = ?";
			PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardFileNo());
			int boardFileRow = boardFileStmt.executeUpdate();
			
			if(boardFileRow == 1){
				System.out.println("수정성공");
			} else {
				System.out.println("수정실패");
			}
		}		
		
	}

	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
%>
